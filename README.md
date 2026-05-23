# dot-nixos

Multi-host, multi-user NixOS flake with decoupled user/host configs, SOPS-based
secrets management, builtin impermanence, quality of life "just" recipe and
nix library overlays for common tasks, and sensible defaults for customization

## Project structure

```
├── docs
├── features
├── hosts
├── overlays
├── profiles
├── scripts
├── secrets
├── templates
├── users
├── utilities
├── flake.lock
├── flake.nix
├── justfile
├── LICENSE
├── meta.json
└── README.md
```

- `meta.json`: hosts various public-facing host, user and general configuration
- `justfile`: where all convenient scripts are included, run `just` for details
- `.sop.yaml`: contains public keys and sops-nix rules
- `modules/`: contains standalone flakes
- `secrets/`: sops-age encrypted secrets live here
- `scripts/`: where "just" modules, iso-embedded scripts and internal scripts live
- `utilities/`: extended functionalities, or overlays if you will, on top of nix `lib`
  along with standalone modules (named with suffix "-builder") to abstract away
  common patterns
- `templates/`: nix templates, try to be as generic as possible
- `overlays/`: customization on top of existing packages or derivations of packages
  not in nixpkgs
- `features/`: contains system-level modules that can be imported to `nixosConfigurations`
  or system configuration required by some packages, e.g., `steam` and `hyprland`
- `profiles/`: contains user-level modules that can be imported to `homeConfigurations`
- `hosts/`: consumer of `features/`, has an opinionated structure. `hardware-configuration`
  is renamed to `generated.nix` and imported by `hardware.nix`. `disko.nix` and `persist.nix`
  must always be present for partitioning and persistence, respectively
- `users/`: likewise, has an opinionated structure and consumer of `profiles/`.
  Worth noting that `system.nix` and `persist.nix` lives in system space rather than user space. Think of
  `system.nix` like a bridge between the two spaces. `system.nix` exists because
  users cannot be fully independent of the hosts they live in. For instance, user passwords,
  impermanence and parts of some packages' configuration must live at system-level. That said, the
  inconsistency space is quite small and has mostly been abstracted away

## Philosophy

### 1. Anything that may be declarative, shall be, by all means, declarative

### 2. User-level configuration must be, or attempted to be independent of system-level configuration

### 3. Opinionated by nature, but with sensible defaults and abstractions to support customization and extensibility

For consistency, many instances of IoC exist throughout the codebase. Thus, there exists
a few conventions:

- Modules in `profiles/` and `features/` are config modules and expected to at least define the
  `options` and `configs` fields (see [defineConfigModule](./utilities/modules.nix))
- A `utilities/` module are autoloaded
- `persist.nix` (both user level and system level) is only an attribute set accepting
  2 fields: `directories` and `files`
- Each host defined in `hosts/` must contain `disko.nix`, `persist.nix`,`hardware.nix`,
  `system.nix` and `generated.nix` (`hardware-configuration.nix`). Also, check
  [persist-common](./modules/persist-common.nix) to see if your persistence directories
  are already included by default

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
For supported architectures, take a look at the `supported` field in [meta.json](meta.json)

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
and it is possible to print their unencrypted values to the terminal in bootstrap 
environment.

### 2. Bootstrap & Install

If you don't have an internet cable connecting to your router, you can use `nmtui` to 
select and connect to a Wi-Fi network. Let the command to retrieve the value of the host 
SSH key be `<host_key_command>` and the hostname be `perseus`

```bash
nixos-bootstrap perseus <host_key_command>
```

You will need to confirm at some steps during bootstrapping so be sure to check back 
once in a while. Once done, your machine will reboot and you will be prompted to the 
`tty` screen. Login to your primary user account then run

```bash
nixos-homestrap <user_key_command>
```

Your system will reboot one more time and that's it.
