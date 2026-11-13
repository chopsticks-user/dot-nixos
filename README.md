# dot-nixos

A NixOS framework that turns a handful of Nix files into one machine with any
number of users. It comes with SOPS-based secrets management, built-in
impermanence, embedded Home Manager, an installer that sets a machine up from
its repository, and a set of opinionated feature modules with sensible
defaults.

## Using the framework

A machine is its own flake. It takes this flake as its only input and points
`mkMachine` at the directory holding the machine files, usually the flake
itself:

```nix
{
  inputs.dot-nixos.url = "github:chopsticks-user/dot-nixos";
  outputs = { dot-nixos, ... }: dot-nixos.lib.mkMachine ./.;
}
```

`mkMachine` returns `{ nixosConfigurations.<networking.hostName> = ...; }`, so
`nixos-rebuild switch --flake .#<hostname>` works from the machine flake.

| Document | For |
|----------|-----|
| [docs/guide.md](docs/guide.md) | Creating, installing and running a machine, with the full option and module reference |
| [docs/design.md](docs/design.md) | The decisions behind the framework and what each one costs |
| [docs/backlog.md](docs/backlog.md) | What has been done and the small tasks that are next |
| [docs/roadmap.md](docs/roadmap.md) | Where the framework is going: a NixOS machine generator |
| [docs/testing.md](docs/testing.md) | How the framework is and will be tested |

Every directory in [examples/](examples) is a complete machine flake.
[examples/andromeda](examples/andromeda) has two users on a persistent root.
[examples/perseus](examples/perseus) has one user on a tmpfs root with
impermanence (`system/persist.nix`), Wi-Fi from secrets, a system service, an
overlay and a patch. The examples point at this repository with `path:../..`,
so they always build against the working tree. The root flake also exposes
each example's `nixosConfigurations` by calling the example's `outputs` with
itself, so `nix flake check` at the root covers them and `.#andromeda` and
`.#perseus` build from the root too.

## Machine layout

```
machine/
├── flake.nix               required  calls dot-nixos.lib.mkMachine ./.
├── secrets.yaml            required  sops file: password/root, password/<user>, networking/wifi/<name>
├── system/
│   ├── default.nix         required  NixOS module: hostname, stateVersion, imports the parts below
│   ├── *.nix               optional  any further parts, e.g. modules.nix, imported by default.nix
│   └── persist.nix         optional  { directories; files }, enables impermanence when present
├── hardware/
│   ├── default.nix         required  NixOS module for the physical machine, usually imports generated.nix
│   ├── disk.nix            required  disko layout
│   └── generated.nix       optional  nixos-generate-config output, by convention
├── overlays/               optional  <attr>/ changes pkgs.<attr> with package.nix and/or *.patch, on top of the framework's
└── users/
    └── <user>/             one directory per user, the name is the username
        ├── home.nix        required  Home Manager module: user.* and modules.*
        ├── persist.nix     optional  { directories; files } for this user
        └── secrets.yaml    optional  this user's sops file
```

Machine-wide facts use native NixOS options (`networking.hostName`,
`time.timeZone`, `system.stateVersion`, `boot.kernelPackages`). Framework
settings that have no native option live under `machine.*` in `system/`
(see [modules/core/machine-options.nix](modules/core/machine-options.nix)).
Per-user settings live under `user.*` in `home.nix` (see
[modules/core/user-options.nix](modules/core/user-options.nix)). That includes
the account fields (`description`, `groups`, `shell`), which the system side
reads back to create the account.

## Overlays

An overlay is any change on top of nixpkgs: a new package, a replaced or
rewrapped package, or patches to an existing one. All of them live in
`overlays/<attr>/`, one directory per package attribute, the same way nixpkgs
keeps `package.nix` and its patches side by side in `pkgs/by-name`. There is
no separate `patches/` directory.

What the directory contains decides what happens to `pkgs.<attr>`:
- `package.nix` defines or replaces `pkgs.<attr>`. It is called like any
  `callPackage` file, and also receives `prev` if it declares that argument.
- `*.patch` files are appended to the package's patches in file name order.
  Without a `package.nix` they patch the existing `pkgs.<attr>`. With one,
  they patch its result, which then has to be a `mkDerivation` package.
- Other files, such as `versions.nix` in
  `examples/andromeda/overlays/unreal-engine`, are ignored. A directory with
  neither a `package.nix` nor a patch fails evaluation.

Only top-level attributes are supported, so `python3Packages.foo` cannot be
changed this way. Patches must apply to the exact upstream source and keep
upstream tests passing.

Overlays come in two layers that use the same layout.
[lib/overlays.nix](lib/overlays.nix) wires both, so nobody edits
`nixpkgs.overlays` for them. The system and every user get the same result.

1. **Framework layer.** The repository's `overlays/` is framework policy,
   together with overlays from the framework's flake inputs, such as
   `llm-agents`, whose packages appear as `pkgs.llm-agents.<name>`. It is
   always applied, every machine inherits the resulting packages, and
   machines cannot switch it off or configure it. The repository's
   `overlays/` is currently empty.
2. **Machine layer.** A machine's own `overlays/` is applied on top. A
   machine that needs something different writes its own overlay instead of
   touching the framework's, and sees the framework's package as `prev`.

Within a layer, overlays apply in directory name order, so `prev` already
includes the changes from directories whose names sort earlier.

[examples/perseus](examples/perseus) shows both kinds:
- `overlays/seanime-server/package.nix` wraps seanime with its server flags
  and exposes the port, and the service and firewall use that port.
- `overlays/hello/0001-greet-from-perseus.patch` changes hello's greeting,
  including the upstream test that checks it.

## Project structure

- `flake.nix`: exports `lib.mkMachine`, `checks`, `formatter` and installer ISOs
- `lib/`: framework internals. `mk-machine.nix` (the builder), `peruser.nix`
  (system side of each user), `overlays.nix` (overlay wiring), `iso.nix`
  (installer), and the helpers listed in `lib/default.nix` (`attrs.nix`,
  `modules.nix`, `packages.nix`), whose exports are merged into nix `lib` as
  `lib.<name>`
- `modules/`: one directory per module, see below
- `overlays/`: the framework's package layer, always applied to every machine
- `scripts/`: the scripts installed on machines and the installer
  (`bootstrap.sh`, `homestrap.sh`, `secrets.sh`, `nix-system.sh`, `open.sh`)
- `tests/`: flake checks for `lib/` helpers, run by `nix flake check`
- `examples/`: user space: machine directories consumed by `mkMachine`
- `docs/`: the documents listed above
- `justfile`: `just flash`, which builds and writes the installer

## Modules

A module is a directory `modules/<name>/` with a `system.nix` (NixOS half),
a `home.nix` (Home Manager half), or both. Both halves are config modules
(see `defineModule` in [lib/modules.nix](lib/modules.nix)). They
return `options`, `configs` and optionally `imports`, `assertions`,
`allowUnfree` and `persist`. Both halves share the `modules.<name>` namespace.

- Enabling a module in a user's `home.nix` turns on its home half for that
  user and its system half for the machine. For example, a user enabling
  `modules.gaming` gets Steam installed system-wide.
- Enabling a module in `system/` turns on its system half only, which is
  how machine-only modules such as `grub` or `nh` are used.
- `core` is always on. It holds only what the framework needs everywhere:
  sops, networking, the framework scripts and the home paths the framework
  creates. Personal tooling lives in opt-in modules such as `cli` and `theme`.
- `allowUnfree` lists package names allowed regardless of the enable flag.
  It has to stay outside the guard, because the system half's enable flag is
  derived from Home Manager, which itself needs the system's nixpkgs.
- `persist.home` in a system half lists home paths to keep under impermanence.
  These are applied only to users who enabled that module. Modules without
  a home half apply to every user. `persist.system` lists system paths and is
  ignored on machines without impermanence.

Adding a directory to `modules/` or `overlays/` is picked up automatically. New
`lib/` helpers are added to the list in `lib/default.nix`.

The full list of modules, their options and what they persist is in
[docs/guide.md](docs/guide.md#76-modules).

## Philosophy

### 1. Anything that may be declarative, shall be, by all means, declarative

### 2. A user is described in one place

Everything about a user, from account fields to dotfiles, lives in
`users/<user>/home.nix`. The system side follows from what users enable.

### 3. Opinionated by nature, but with sensible defaults and abstractions to support customization and extensibility
