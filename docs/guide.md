# Using dot-nixos

This guide is for people who want to run their own machine on dot-nixos. It
covers creating a machine repository, generating its keys and secrets,
installing it, and operating it afterwards. The design reasoning lives in
[design.md](design.md); this file only describes how things work today.

## Contents

1. [How it fits together](#1-how-it-fits-together)
2. [Prerequisites](#2-prerequisites)
3. [Create the machine repository](#3-create-the-machine-repository)
4. [Keys and secrets](#4-keys-and-secrets)
5. [Install](#5-install)
6. [Day-to-day operation](#6-day-to-day-operation)
7. [Reference](#7-reference)
8. [Limitations](#8-limitations)

## 1. How it fits together

A machine is a flake of its own, usually a git repository with `flake.nix` at
its root. The flake takes dot-nixos as its only input and hands its own
directory to `dot-nixos.lib.mkMachine`:

```nix
{
  inputs.dot-nixos.url = "github:chopsticks-user/dot-nixos";
  outputs = { dot-nixos, ... }: dot-nixos.lib.mkMachine ./.;
}
```

`mkMachine` reads the directory by convention and returns
`{ nixosConfigurations.<networking.hostName> = ...; }`. Everything the machine
needs is pinned by the framework's own inputs (nixpkgs, Home Manager, disko,
sops-nix, impermanence and a few module inputs), so one `nix flake update
dot-nixos` moves the whole machine forward.

The machine directory has three kinds of content:

| Part | Where | What it holds |
|------|-------|---------------|
| Machine | `system/`, `hardware/`, `secrets.yaml` | NixOS modules for the machine, the disk layout, the host secrets |
| Users | `users/<name>/` | One directory per user: a Home Manager module, optional persistence list and secrets |
| Packages | `overlays/` | Packages added, replaced or patched for this machine |

Home Manager is embedded in the system build. There is no separate home
switch: building the machine builds every user's home.

Features come as modules under `modules.<name>`. Each module may have a system
half and a home half. Enabling a module in a user's `home.nix` turns on its
home half for that user and its system half for the whole machine. Modules
with only a system half, such as `grub`, are enabled in `system/`. The system
half of a module with both halves is read-only: setting it in `system/` is an
evaluation error, so it can only follow the users.

## 2. Prerequisites

You need a machine already running NixOS with flakes enabled. This guide calls
it the dev machine: it holds the repository, generates keys and encrypts
secrets. If it runs dot-nixos itself, it already has `nixos-secrets`, `sops`,
`ssh-to-age` and `git`. Otherwise run the commands below through
`nix shell nixpkgs#sops nixpkgs#ssh-to-age nixpkgs#git`.

The new machine needs network access during installation, and something it
can run to print each private key. In this guide that is SSH to the dev
machine, which therefore needs `sshd` with password login, as the `ssh` module
sets up.

## 3. Create the machine repository

### 3.1 Start from an example

Copy one of the examples into a new repository:

- [examples/perseus](../examples/perseus): one user, tmpfs root with
  impermanence, Wi-Fi from secrets, a system service, an overlay and a patch.
- [examples/andromeda](../examples/andromeda): two users on a persistent
  root, extra flake outputs (templates) next to the machine.

```bash
cp -r examples/perseus ~/projects/mymachine
cd ~/projects/mymachine
rm -f secrets.yaml users/*/secrets.yaml flake.lock
git init
```

Point the input at the framework instead of the relative path the examples
use, and pin a branch or tag if you want one:

```nix
inputs.dot-nixos.url = "github:chopsticks-user/dot-nixos";
```

Flakes only see files that git tracks. Run `git add -A` before every build,
or new files are silently missing.

### 3.2 Layout

```
mymachine/
├── flake.nix               required  calls dot-nixos.lib.mkMachine ./.
├── secrets.yaml            required  host secrets, see 4.3
├── .sops.yaml              needed    sops recipients, see 4.2
├── system/
│   ├── default.nix         required  NixOS module: hostname, stateVersion, imports the rest
│   ├── *.nix               optional  further NixOS modules, imported by default.nix
│   └── persist.nix         optional  { directories; files; } turns on impermanence
├── hardware/
│   ├── default.nix         required  NixOS module for the hardware, usually imports generated.nix
│   ├── disk.nix            required  disko layout, used by the installer and at boot
│   └── generated.nix       optional  nixos-generate-config output, by convention
├── overlays/               optional  <attr>/package.nix and/or <attr>/*.patch
└── users/
    └── <name>/             one directory per user, the name is the username
        ├── home.nix        required  Home Manager module: user.* and modules.*
        ├── persist.nix     optional  { directories; files; } relative to home
        └── secrets.yaml    optional  this user's secrets, see 4.3
```

Missing required files fail evaluation with
`mkMachine: <path> is required`.

### 3.3 system/default.nix

`system/default.nix` is an ordinary NixOS module. It must set the host name
(it names the output) and `system.stateVersion`:

```nix
{
  imports = [ ./modules.nix ];

  networking.hostName = "mymachine";
  time.timeZone = "Europe/Berlin";
  system.stateVersion = "26.11";
}
```

Use native NixOS options for everything they cover. The framework adds options
only where none exist: `machine.*` (paths, see 7.3) and `modules.*` (features,
see 7.6). A typical `system/modules.nix`:

```nix
{
  modules = {
    grub.enable = true;
    nh.enable = true;
    cli.enable = true;
    # Wi-Fi network "home": ssid and password come from secrets.yaml
    core.wifi.home.priority = 101;
  };
}
```

Machine modules receive the framework's flake inputs as `inputs`, so
`inputs.nixos-hardware.nixosModules.*` is available without adding an input to
your flake.

### 3.4 Hardware

`hardware/generated.nix` is the output of `nixos-generate-config` for the real
machine. Generate it from the installer on the target before installing (5.2),
because the install builds from the repository and needs it committed:

```bash
nixos-generate-config --no-filesystems --show-hardware-config > generated.nix
```

`--no-filesystems` matters: file systems come from `disk.nix`.
`hardware/default.nix` imports it and adds the rest, typically
`nixos-hardware` profiles and GPU drivers (see the examples for NVIDIA,
including PRIME).

`hardware/disk.nix` is a [disko](https://github.com/nix-community/disko)
layout. Address the disk by id so the layout survives reordering:

```bash
ls -l /dev/disk/by-id/
```

The installer wipes and formats exactly what `disk.nix` describes.

### 3.5 Impermanence

Adding `system/persist.nix` turns on impermanence. The root file system is
expected to be temporary (tmpfs or a wiped subvolume), with a `/persist` file
system that survives reboots. perseus shows the layout: tmpfs `/`, btrfs
subvolumes for `/persist` and `/nix`.

`system/persist.nix` is a plain attribute set, not a module. It lists only
what the machine adds, and may be `{ }`:

```nix
{
  directories = [ "/var/lib/bluetooth" ];
  files = [ ];
}
```

The framework (core) already keeps `/var/log`, `/var/db/sudo/lectured`,
`/var/lib/nixos`, `/var/lib/sops-nix`, `/var/lib/NetworkManager`,
`/var/lib/systemd/coredump`, `/etc/NetworkManager/system-connections`,
`/etc/machine-id` and the directory of the host key (`/etc/ssh`), so `sshd`
keeps its host key. sops itself reads the host key from
`/persist/etc/ssh/ssh_host_ed25519_key`, because it decrypts before the bind
mounts exist.

What survives in home directories is assembled for each user from three
sources, all relative to the home directory:

| Source | Applies to |
|--------|------------|
| The framework (core) | Every user: the directory of the user key (`.ssh`, mode 0700), the flake checkout, nix and Home Manager state (`.local/state/nix`, `.local/state/home-manager`, `.cache/nix`), user secrets (`.config/sops-nix`), and the data directories `documents`, `downloads`, `projects`, `media` (and any of `pictures`, `music`, `videos` moved outside them) |
| A module's `persist.home` | Users who enabled that module, for example `.mozilla` for `firefox` |
| `users/<name>/persist.nix` | That user: anything else, same shape as `system/persist.nix` |

Listing the same path twice fails evaluation, so do not repeat in
`persist.nix` what the framework or a module already keeps. Machines without
`system/persist.nix` ignore all of this.

### 3.6 Users

Each directory under `users/` becomes a normal user with that name.
`users/<name>/home.nix` is a Home Manager module, and everything about the
user lives there, account fields included:

```nix
{ pkgs, ... }:
{
  user = {
    description = "Alice";
    groups = [ "wheel" "networkmanager" "video" ];
  };

  modules = {
    zsh.enable = true;      # also makes zsh the login shell
    git = {
      enable = true;
      identityFromSecrets = true;   # git/name and git/email from users/alice/secrets.yaml
    };
    hyprland.enable = true; # also enables the theme and sets kitty as terminal
    firefox.enable = true;
  };

  user.allowUnfree = [ "obsidian" ];
  home.packages = with pkgs; [ obsidian ];
}
```

The system side reads `user.description`, `user.groups` and `user.shell` back
to create the account, and takes the password hash from `password/<name>` in
the host `secrets.yaml`. `home.stateVersion` defaults to the machine's
`system.stateVersion`.

### 3.7 Unfree packages

Allow unfree packages by name where you install them:
`nixpkgs.config.allowUnfreePackages = [ ... ]` in `system/` for system
packages, `user.allowUnfree = [ ... ]` in `home.nix` for that user's packages.
All users share the system's nixpkgs, so a name one user allows is allowed on
the whole machine. Home Manager rejects `nixpkgs.*` in `home.nix`. Framework
modules already allow what they install.

### 3.8 Overlays and patches

`overlays/<attr>/` changes `pkgs.<attr>` for the machine and every user:

| Contents | Effect |
|----------|--------|
| `package.nix` | Defines or replaces `pkgs.<attr>`. Called like a `callPackage` file; it also receives `prev` (the package below this layer) if it declares that argument |
| `*.patch` | Appended to the package's patches in file name order. Without `package.nix` they patch the existing `pkgs.<attr>`; with it, they patch its result, which must then be a `mkDerivation` package |
| both | `package.nix` builds the package, then the patches apply to it |

Other files in the directory, such as helpers `package.nix` imports, are
ignored. A directory with neither file fails evaluation. Only top-level
attributes work, so `python3Packages.foo` cannot be changed this way.
Directories apply in name order, so `prev` already includes earlier
directories.

The framework applies its own layer first. Today that layer holds only the
[llm-agents](https://github.com/numtide/llm-agents.nix) overlay, which adds
`pkgs.llm-agents.<name>`. Your overlays apply on top and see the framework's
packages as `prev`.

perseus has both kinds: `overlays/seanime-server/package.nix` wraps a package
with server flags, and `overlays/hello/0001-greet-from-perseus.patch` patches
hello, including the upstream test that checks its output. A patch must apply
to the exact upstream source and keep upstream tests passing; write it with
`diff -u` against the unpacked `src`.

## 4. Keys and secrets

### 4.1 Generate the keys

Every machine has one host SSH key, and every user one user SSH key.
[sops-nix](https://github.com/Mic92/sops-nix) converts them to age keys: the
host key decrypts `secrets.yaml` during boot, and each user key decrypts that
user's `secrets.yaml` when their home is activated.

Generate all of a new machine's keys on the dev machine, outside the
repository:

```bash
cd ~/keys
nixos-secrets new mymachine alice bob
```

This writes `~/keys/mymachine.tar.gz` (mode 600) with `root.key` for the host
and `<user>.key` for each user, and prints their age public keys:

```
Age public keys for .sops.yaml:
  host mymachine: age1...
  user alice: age1...
  user bob: age1...
```

The archive is the only copy of the private keys. `nixos-secrets` never
overwrites an existing archive. Keep it somewhere safe; `*.tar.gz` is
gitignored in case it ends up inside a repository.

### 4.2 .sops.yaml

Put a `.sops.yaml` at the root of the machine repository. Paths are matched
relative to the file's directory:

```yaml
keys:
  - &host_mymachine age1...
  - &user_alice age1...
  - &user_bob age1...
  - &admin age1...   # optional: your key on the dev machine
creation_rules:
  - path_regex: ^secrets\.yaml$
    key_groups:
      - age: [ *host_mymachine, *admin ]
  - path_regex: ^users/alice/secrets\.yaml$
    key_groups:
      - age: [ *user_alice, *admin ]
  - path_regex: ^users/bob/secrets\.yaml$
    key_groups:
      - age: [ *user_bob, *admin ]
```

The admin key is optional but useful: with it, you can edit every file from
the dev machine with plain `sops <file>`, since dot-nixos sets
`SOPS_AGE_KEY_CMD` to your user key in every session. Print it with
`nixos-secrets user public`.

### 4.3 Write the secrets

Creating a file only needs the public keys, so this works on the dev machine
before the new machine exists. `nixos-secrets host edit <dir>` and
`nixos-secrets user edit <dir>` open the files in sops and create them from
`.sops.yaml` if missing; plain `sops <file>` from inside the repository works
too.

The host file, `secrets.yaml`:

```yaml
password:
  root: $y$j9T$...      # hash, not the password: mkpasswd -m yescrypt
  alice: $y$j9T$...     # one per user
  bob: $y$j9T$...
networking:
  wifi:
    home:               # one entry per modules.core.wifi.<name>
      ssid: MyNetwork
      password: hunter2
```

Get a hash with `nix run nixpkgs#mkpasswd -- -m yescrypt`.
`password/root` and one `password/<user>` per user are required: users get
their password from it. `networking/wifi/<name>/*` is required only for
networks declared under `modules.core.wifi`.

A user file, `users/<name>/secrets.yaml`, is optional. The framework reads
from it only when the user sets `modules.git.identityFromSecrets`:

```yaml
git:
  name: Alice Example
  email: alice@example.com
```

Your own `home.nix` can declare more `sops.secrets` in either file.

Commit `.sops.yaml` and the encrypted files. They are safe to publish as long
as the private keys are not.

## 5. Install

### 5.1 Build the installer

From a checkout of the framework repository, write the installer ISO to a USB
stick:

```bash
lsblk                         # find the stick
just flash /dev/sdX           # system defaults to the current one, e.g. x86_64-linux
```

`just flash` asks whether to set up automated bootstrapping. Answering no
gives a plain installer with `nixos-bootstrap` on it. Answering yes asks for
Wi-Fi credentials (optional), the machine repository URL, the host name, the
first user, and the two key commands, and bakes them into the ISO so it
installs by itself after login. Those values end up in the Nix store of the
dev machine; `just flash` prints how to remove them.

Without `just`, build the plain ISO directly:

```bash
nix build github:chopsticks-user/dot-nixos#nixosConfigurations.iso-x86_64-linux.config.system.build.isoImage
```

### 5.2 Prepare the hardware configuration

Boot the target from the stick. If `hardware/generated.nix` is not committed
yet, generate it there (3.4), copy it to the dev machine, commit and push.

Make the key archive reachable. In this guide the dev machine serves it over
SSH, so the key commands are:

```bash
ssh you@devmachine 'tar -xOzf ~/keys/mymachine.tar.gz root.key'
ssh you@devmachine 'tar -xOzf ~/keys/mymachine.tar.gz alice.key'
```

Any command that prints the key works.

### 5.3 Bootstrap

Connect to the network (`nmtui` for Wi-Fi), then:

```bash
nixos-bootstrap https://github.com/you/mymachine mymachine \
  "ssh you@devmachine 'tar -xOzf ~/keys/mymachine.tar.gz root.key'"
```

It clones the repository, checks that it has `nixosConfigurations.mymachine`,
runs disko (this erases the disks in `disk.nix`; it asks for confirmation),
writes the host key to the path sops reads (`/etc/ssh/...`, or under
`/persist` with impermanence), and runs `nixos-install`. The repository must
be cloneable from the installer: public, or with credentials you provide.

### 5.4 Homestrap

Reboot into the new system, log in as the user, connect to the network and
run:

```bash
nixos-homestrap https://github.com/you/mymachine \
  "ssh you@devmachine 'tar -xOzf ~/keys/mymachine.tar.gz alice.key'"
```

It clones the repository to `~/.config/nixos` and places the user key at
`~/.ssh/id_ed25519`. It can be run again: it keeps an existing checkout and
key. Reboot once more so the user's secrets decrypt. Repeat for every other
user.

With automated bootstrapping, the ISO runs both steps for the first user and
asks before rebooting.

## 6. Day-to-day operation

### 6.1 Rebuild

The checkout in `~/.config/nixos` (`machine.directories.nixos`) is where
commands look for the flake. Its root flake must expose the host.

| Command | Effect |
|---------|--------|
| `nix system build` | Builds the configuration and shows the package and closure differences to the running system |
| `nix system switch` | Same, then asks before switching |
| `nix system info` | Lists generations |
| `nix system <other>` | Runs `nixos-rebuild <other> --flake ...` for this host |
| `nh os switch` | With the `nh` module, which also cleans old generations |

`nix system` is a wrapper the framework installs in front of `nix`; every other
`nix` command passes through unchanged.

### 6.2 Update

```bash
nix flake update dot-nixos    # framework, and everything it pins
nix system switch
```

To hold back or override one of the framework's inputs, use flake input
overrides, for example
`inputs.dot-nixos.inputs.nixpkgs.url = "github:nixos/nixpkgs/<rev>";`.

### 6.3 Secrets

| Command | Effect |
|---------|--------|
| `nixos-secrets host [edit\|public\|private] [<dir>]` | The machine's `secrets.yaml`, decrypted with the host key (needs sudo) |
| `nixos-secrets user [edit\|public\|private] [<dir>]` | Your `users/<you>/secrets.yaml`, decrypted with your key |
| `nixos-secrets update [<dir>]` | Re-encrypts both files after `.sops.yaml` changed |
| `nixos-secrets new <host> <user>...` | Keys for a new machine, see 4.1 |
| `nixos-secrets backup` | Archives this machine's host key and every user's key into `./<hostname>.tar.gz` |

`<dir>` defaults to the checkout. The host secrets become active on the next
switch; user secrets on the next home activation (switch or reboot).

### 6.4 Add a user

1. Generate a key: `ssh-keygen -t ed25519 -N "" -C bob@mymachine -f bob.key`,
   then `ssh-to-age < bob.key.pub` for the public key.
2. Add the key and a rule for `users/bob/secrets.yaml` to `.sops.yaml`.
3. Add `password/bob` to the host `secrets.yaml`.
4. Create `users/bob/home.nix` (and optionally `persist.nix`, `secrets.yaml`).
5. `git add -A`, switch, then run `nixos-homestrap` as bob.

### 6.5 Back up what is not declarative

Configuration is in the repository; data is not. Back up at least the key
archive (`nixos-secrets backup`), and whatever lives only on the machine:
browser profiles (`~/.mozilla`), GPG keys (`~/.gnupg`), and your data
directories.

## 7. Reference

### 7.1 What mkMachine builds

`mkMachine <dir>` evaluates one NixOS system from:

1. the system halves of all framework modules, with the framework inputs
   (disko, sops-nix, Home Manager) and the overlay layers;
2. `system/default.nix`, `hardware/default.nix`, `hardware/disk.nix`, and
   `secrets.yaml` as the default sops file;
3. Home Manager with every framework home half, sops-nix for users, the
   system's overlays, and one user per `users/<name>/home.nix` (with
   `users/<name>/secrets.yaml` as that user's default sops file);
4. impermanence, when `system/persist.nix` exists, with `/persist` needed for
   boot;
5. per user: the account (from `user.*`), its password secret, and its
   persisted paths.

The system half of a module with both halves is enabled when any user enables
its home half, and nothing else may set it (`readOnly`). `useGlobalPkgs` is on: users share the system's nixpkgs, with
its overlays, and every user's `user.allowUnfree` is added to its unfree
allowlist.

### 7.2 Arguments available to modules

| Argument | In | Value |
|----------|----|-------|
| `inputs` | NixOS and Home Manager modules | The framework's flake inputs: nixpkgs, nixos-hardware, disko, home-manager, sops-nix, impermanence, nix-index-database, nix-alien, nvf, noctalia, steam-config-nix, llm-agents |
| `osConfig` | Home Manager modules | The machine's NixOS config |

The machine flake's own inputs are not passed through ([#16](https://github.com/chopsticks-user/dot-nixos/issues/16)).

### 7.3 machine.* (NixOS)

Framework settings without a native NixOS option, set in `system/`: where the
repository is checked out, the host key, and the well-known home paths. Every
option with its type and default is in [options.md](options.md#nixos-options),
generated from the declarations.

### 7.4 user.* (Home Manager)

Per-user settings, set in `home.nix`: the account fields the system reads back
(`description`, `groups`, `shell`), the terminal, unfree package names and the
resolved home paths. See [options.md](options.md#home-manager-options).

### 7.5 modules.core (always on)

On every machine the framework sets up: flakes, the latest kernel (overridable,
it is a default), NetworkManager with an ethernet profile, the firewall, root's
and every user's password from secrets, sops with the host key, the commands in
6.1 and 6.3 plus `nixos-homestrap`, and `git`, `sops`, `age` and `ssh-to-age`.
For every user it sets the XDG directories from `user.directories`, the user
key as sops identity and `SOPS_AGE_KEY_CMD`.

Its options (ethernet and Wi-Fi priorities, Wi-Fi networks from the host
secrets) are in [options.md](options.md#nixos-options).

### 7.6 Modules

Enable with `modules.<name>.enable = true`. Module options are in
[options.md](options.md). "Home" modules are enabled per user
in `home.nix` and switch on their system half for the machine, which `system/`
cannot set; "system" modules are enabled in `system/`.

| Module | Halves | What it sets up | Persists |
|--------|--------|-----------------|----------|
| `cli` | system | CLI toolkit (ripgrep, fd, jq, yq, btop matched to the GPU, ncdu, nixd, nixfmt, nvd, nix-alien, just, ...), nix-index with comma | |
| `docs` | system | man, info and dev documentation with a man cache, tldr, wikiman | |
| `fcitx` | system | fcitx5 with the Wayland frontend and a US keyboard group; add input methods through native `i18n.inputMethod.fcitx5.addons` and `settings` | |
| `firefox` | home, system | Firefox with a profile named after the user and a few chosen preferences | `.mozilla`, `.cache/mozilla` |
| `gaming` | home, system | Steam (firewall for remote play and dedicated servers), gamemode, gamescope, mangohud, protonup-qt, protontricks, steamcmd, 32-bit graphics | `.local/share/Steam` |
| `git` | home, system | git and gh | `.config/gh`, `.local/state/gh` |
| `grub` | system | GRUB for EFI as removable install, os-prober, remembers the last entry, firmware setup entry | |
| `hyprland` | home, system | Hyprland with the noctalia shell, keybindings, kitty, screenshots to `user.directories.screenshots`, start on tty1 login, default applications for `open`; enables `theme` | Hyprland and noctalia config, data, cache; wireplumber state |
| `llm` | home, system | Claude Code (settings stay writable), nix-ld for downloaded binaries | `.claude` |
| `neovim` | home, system | Neovim through nvf as default editor, with LSP, treesitter and formatting for several languages | `.local/share/nvf` |
| `nh` | system | nh, pointed at the checkout; its periodic clean keeps the last 8 generations and anything newer than 7 days | |
| `obs` | home | OBS Studio, recordings in `user.directories.screencasts` | |
| `open` | home | An `open` command and default applications per category | |
| `ssh` | home, system | sshd (password login on, root login off) and client defaults | |
| `theme` | home | Fira and FiraCode Nerd fonts, emoji, cursor, Adwaita GTK, Qt following GTK, dark or light | |
| `virtualization` | home, system | podman with docker compatibility, distrobox, qemu, quickemu, virt-manager, emulation of aarch64 and riscv64 | `boxes` |
| `vscode` | home, system | VS Code with extensions and language servers pinned to the store | `.config/Code` |
| `zed` | home, system | Zed with Nix support | Zed data and cache |
| `zsh` | home, system | zsh with completion, suggestions, highlighting and history, zoxide as `cd`, fzf; makes zsh the login shell | `.config/zsh`, zoxide data, `.zsh_history` |

### 7.7 Commands

| Command | Where | Purpose |
|---------|-------|---------|
| `nixos-bootstrap [--no-reboot] <repo-url> <host> <host-key-command>` | installer | Partition, place the host key, install |
| `nixos-homestrap [--no-reboot] <repo-url> <user-key-command>` | every machine | Clone the repository, place the user key |
| `nixos-secrets ...` | every machine | Secrets and keys, see 6.3 |
| `nix system ...`, `nix-system ...` | every machine | Rebuild, see 6.1 |
| `open [-s <cmd>] [-p] [-c <cmd>] [-k] <target>` | with `open` | `xdg-open` with an fzf picker (`-s`), project picker (`-p`) and custom command (`-c`) |
| `just flash [device] [system]` | framework checkout | Build and write the installer |

The machine scripts take `NIXOS_FLAKE_DIR` and `NIXOS_HOME_IDENTITY` from the
environment to override `machine.directories.nixos` and
`machine.directories.home.identity`.

## 8. Limitations

Known limitations and planned work are the [open issues](https://github.com/chopsticks-user/dot-nixos/issues) on GitHub.
