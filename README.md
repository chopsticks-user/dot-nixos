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
| [docs/guide.md](docs/guide.md) | Creating, installing and running a machine, with the module and command reference |
| [docs/options.md](docs/options.md) | Every framework option with its type and default, generated from the declarations |
| [docs/design.md](docs/design.md) | The decisions behind the framework and what each one costs |
| [docs/backlog.md](docs/backlog.md) | The coding log: every finished change as a pull request, with why, what and how it was verified |
| [docs/issues.md](docs/issues.md) | The issue tracker: known problems and planned work, open and closed |
| [docs/roadmap.md](docs/roadmap.md) | Where the framework is going: a NixOS machine generator |
| [docs/testing.md](docs/testing.md) | How to run the tests, what each one covers, and what is still missing |

Every directory in [examples/](examples) is a complete machine flake.
[examples/andromeda](examples/andromeda) has two users on a persistent root.
[examples/perseus](examples/perseus) has one user on a tmpfs root with
impermanence (`system/persist.nix`), Wi-Fi from secrets, a system service, an
overlay and a patch. The examples point at this repository with `path:../..`,
so they always build against the working tree. The root flake also exposes
each example's `nixosConfigurations` by calling the example's `outputs` with
itself, so `nix flake check` at the root covers them and `.#andromeda` and
`.#perseus` build from the root too.

## How it works

- **A machine is a directory.** `system/` and `hardware/` hold NixOS modules
  and the disk layout, `users/<name>/home.nix` describes each user, and
  `secrets.yaml` holds the sops-encrypted host secrets. Adding
  `system/persist.nix` turns on impermanence. See the
  [layout](docs/guide.md#32-layout).
- **Home Manager is embedded.** One build covers the system and every home.
  The system reads each user's account fields (`user.*`) back from their
  `home.nix`.
- **Features are modules.** `modules.<name>.enable` in a user's `home.nix`
  turns on that user's half and the machine's half; machine-only modules are
  enabled in `system/`. See the [module list](docs/guide.md#76-modules) and
  the generated [option reference](docs/options.md).
- **Packages change through overlays.** `overlays/<attr>/` with a
  `package.nix` and/or `*.patch` files changes `pkgs.<attr>` for the machine
  and every user, on top of the framework's own layer. See
  [overlays and patches](docs/guide.md#38-overlays-and-patches).

## Philosophy

### 1. Anything that may be declarative, shall be, by all means, declarative

### 2. A user is described in one place

Everything about a user, from account fields to dotfiles, lives in
`users/<user>/home.nix`. The system side follows from what users enable.

### 3. Opinionated by nature, but with sensible defaults and abstractions to support customization and extensibility
