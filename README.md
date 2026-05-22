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
Worth noting that `system.nix` lives in system space rather than user space. Think of 
`system.nix` like a bridge between the two spaces. `system.nix` exists because 
users cannot be fully independent of the hosts they live in. For instance, user passwords 
and parts of some packages' configuration must live at system-level. That said, the 
inconsistency space is quite small and has mostly been abstracted away

## Philosophy

### 1. Anything that may be declarative, shall be, by all means, declarative



### 2. User-level configuration must be, or attempted to be independent of system-level configuration



### 3. Opinionated by nature, but with sensible defaults and abstractions to support customization and extensibility

For consistency, many instances of IoC exist throughout the codebase. A consequence 
of this is that files are expected to be named in a certain way, below is a list of 
examples:

- 

`features` and `profiles` are good examples of IoC

## Installation guide

### 1. Generate a host key and a primary user's key

### 2. Bootstrap

### 3. Install
