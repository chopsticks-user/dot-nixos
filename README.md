# dot-nixos

A NixOS framework that turns a handful of Nix files into one machine with any
number of users. It comes with SOPS-based secrets management, built-in
impermanence, embedded Home Manager, "just" recipes, and nix library helpers.
It provides sensible defaults for customization.

## Using the framework

A machine is its own flake. It takes this flake as an input and points
`mkMachine` at the directory holding the machine files, usually the flake itself:

```nix
{
  inputs.dot-nixos.url = "github:chopsticks-user/dot-nixos";
  outputs = { dot-nixos, ... }: dot-nixos.lib.mkMachine ./.;
}
```

`mkMachine` returns `{ nixosConfigurations.<networking.hostName> = ...; }`, so
`nixos-rebuild switch --flake .#<hostname>` works from the machine flake.

Every directory in [examples/](examples) is a complete machine flake.
[examples/andromeda](examples/andromeda) has two users. The examples point at
this repository with `path:../..`, so they always build against the working
tree. The root flake also exposes each example's `nixosConfigurations` by
calling the example's `outputs` with itself, so `nix flake check` at the root
covers them and `.#andromeda` builds from the root too.

## Machine layout

```
machine/
├── flake.nix               required  calls dot-nixos.lib.mkMachine ./.
├── flake.lock
├── secrets.yaml            required  sops file: password/root, password/<user>, wifi
├── system/
│   ├── default.nix         required  NixOS module: hostname, stateVersion, modules.*, anything NixOS
│   └── persist.nix         optional  { directories; files }, enables impermanence when present
├── hardware/
│   ├── default.nix         required  NixOS module for the physical machine, usually imports generated.nix
│   ├── disk.nix            required  disko layout
│   └── generated.nix       optional  nixos-generate-config output, by convention
└── users/
    └── <user>/             one directory per user, the name is the username
        ├── home.nix        required  Home Manager module: user.* and modules.*
        ├── persist.nix     optional  { directories; files } for this user
        └── secrets.yaml    optional  this user's sops file
```

Machine-wide facts use native NixOS options (`networking.hostName`,
`system.stateVersion`, `boot.kernelPackages`, `nixpkgs.overlays`). Framework
settings that have no native option live under `machine.*` in `system/default.nix`
(see [modules/core/machine-options.nix](modules/core/machine-options.nix)). Per-user settings live under
`user.*` in `home.nix` (see [modules/core/user-options.nix](modules/core/user-options.nix)).
That includes the account fields (`description`, `groups`, `shell`), which
the system side reads back to create the account.

Overlays from [overlays/](overlays) are enabled with
`nixpkgs.overlays = [ (lib.mkOverlay "<name>" { ...args }) ];` in `system/default.nix`.
Users get the same overlays in their own nixpkgs instance.

## Project structure

- `flake.nix`: exports `lib.mkMachine`, `templates`, `formatter` and installer ISOs
- `lib/`: framework internals. `mk-machine.nix` (the builder), `peruser.nix`
  (system side of each user), `iso.nix` (installer), and the helpers listed in
  `lib/default.nix` (`attrs.nix`, `modules.nix`, `packages.nix`), whose exports
  are merged into nix `lib` as `lib.<name>`
- `modules/`: one directory per module, see below
- `overlays/`: customization on top of existing packages, or packages not in nixpkgs
- `scripts/`: "just" modules, ISO-embedded scripts and internal scripts
- `templates/`: nix flake templates, as generic as possible
- `examples/`: user space: machine directories consumed by `mkMachine`
- `docs/secrets/`: plaintext skeletons of the expected sops files

## Modules

A module is a directory `modules/<name>/` with a `system.nix` (NixOS half),
a `home.nix` (Home Manager half), or both. Both halves are config modules
(see `defineModule` in [lib/modules.nix](lib/modules.nix)). They
return `options`, `configs` and optionally `imports`, `assertions`,
`allowUnfree` and `persist`. Both halves share the `modules.<name>` namespace.

- Enabling a module in a user's `home.nix` turns on its home half for that
  user and its system half for the machine. For example, a user enabling
  `modules.gaming` gets Steam installed system-wide.
- Enabling a module in `system/default.nix` turns on its system half only, which is
  how machine-only modules such as `grub` or `nh` are used.
- `core` is always on.
- `allowUnfree` lists package names allowed regardless of the enable flag.
  It has to stay outside the guard, because the system half's enable flag is
  derived from Home Manager, which itself needs the system's nixpkgs.
- `persist.home` in a system half lists home paths to keep under impermanence.
  These are applied only to users who enabled that module. Modules without
  a home half apply to every user.

Adding a directory to `modules/` or `overlays/` is picked up automatically. New
`lib/` helpers are added to the list in `lib/default.nix`.

## Philosophy

### 1. Anything that may be declarative, shall be, by all means, declarative

### 2. A user is described in one place

Everything about a user, from account fields to dotfiles, lives in
`users/<user>/home.nix`. The system side follows from what users enable.

### 3. Opinionated by nature, but with sensible defaults and abstractions to support customization and extensibility

## Installation guide

### 1. Prerequisites

Let's assume, for the sake of arguments, that you will not encounter any errors during
the next two phases: bootstrapping and installation (I know, I know). Then, what you
need to do in the two phases can be boiled down to

- Ensure you have internet connection, either via `network-manager` (`nmtui` or `nmcli`)
  or a network cable
- Prepare two commands that return your host's and a primary user's SSH keys (no passphrase),
  respectively. The former will be used for bootstrapping while the latter for installation

In that case, the most challenging part is preparation, which is what we will be discussing.
If you are running a non-NixOS GNU/Linux systems, you might be able to use docker for
the following instructions, which expect you to already have a NixOS system.

First, you need to generate an iso for installation. Make sure you know what
output device will contain the iso by running `lsblk` and the architecture of
the system you will be using. You can then run `just flash` with or without
the two arguments, which default to `/dev/sda` and `x86_64-linux`, respectively.
For supported architectures, take a look at `supported` in [flake.nix](flake.nix)

Create your host SSH key by enabling `openssh` simply running

```bash
ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key
```

if you don't already have a key or simply want to use another key. Then, create
at least one user SSH key by either configuring your user SSH or running,

```bash
ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -N "" -f $HOME/.ssh/id_ed25519 
```

Lastly, run `just secrets backup` to generate a `tar.gz` archive whose name is the 
hostname of your current system. You can send archive before sending the archive to 
a remote host. Make sure you encrypt the archive if the remote host is not trusted.
Suppose my remote SSH connection is `frost@andromeda` and `perseus` is the hostname
of the new system. 

```bash
rsync -av --remove-source-files "secrets/$(hostname).tar.gz" frost@andromeda:/tmp/
```

To retrieve the private host key during bootstrapping

```bash
ssh frost@andromeda 'tar -xOzf /tmp/perseus.tar.gz root.key'
```

Similarly, during installation, assume `tester` is the primary user 
```bash
ssh frost@andromeda 'tar -xOzf /tmp/perseus.tar.gz tester.key'
```

In short, you need a host SSH key + a user SSH key stored somewhere safe, 
and ensure there exists a command to print their unencrypted values to the terminal 
in bootstrap environment.

### 2. Bootstrap & Install

If you don't have an internet cable connecting to your router, you can use `nmtui` to 
select and connect to a Wi-Fi network. Let the command to retrieve the value of the host 
SSH key be `<host_key_command>` and the hostname be `perseus`

```bash
nixos-bootstrap perseus <host_key_command>
```

You will need to confirm at some steps during bootstrapping so be sure to check back 
once in a while. Once done, reboot your machine and you will be prompted to the 
`tty` screen. Login to your primary user account, connect to the Wi-Fi network, then run

```bash
nixos-homestrap <user_key_command>
```

This clones the flake and places your user key so your user secrets can be
decrypted. Home Manager is part of the system build, so there is no separate
home switch. Reboot your machine one more time and that's it.
