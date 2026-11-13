# CLAUDE.md

@README.md

The README above is the source of truth for what the framework is and how it is
used. This file only adds what an agent needs to work in the repo safely.
Update the README, not this file, when the user-facing design changes.

## Where things live

| Path | What it is |
|------|------------|
| `flake.nix` | Framework flake: `lib.mkMachine`, `checks`, `formatter`, ISOs. It also exposes each example's `nixosConfigurations` by calling the example's `outputs { dot-nixos = self; }`. |
| `lib/mk-machine.nix` | The builder. Reads the machine directory, wires embedded Home Manager, and auto-enables system halves. |
| `lib/modules.nix` | `defineModule`, plus discovery of `modules/*/system.nix` and `modules/*/home.nix`. |
| `lib/overlays.nix` | The only place that writes `nixpkgs.overlays`: the framework's `overlays/` (always on), then the machine's on top. |
| `lib/peruser.nix` | System side of one user: account, password secret, per-user persistence. Curried with `{ username, userPersist }`. |
| `lib/packages.nix`, `lib/attrs.nix` | Helpers merged into `lib`. `lib/default.nix` lists helper files explicitly, so a new helper file must be added there. |
| `tests/` | Flake checks for `lib/` helpers, with fixtures (`checks.<system>.lib-packages`). |
| `modules/<name>/` | Feature modules. `system.nix` is the NixOS half and `home.nix` the Home Manager half, both under the `modules.<name>` namespace. |
| `modules/core/` | Always-on module. It declares `machine.*`, `persist.home` (NixOS) and `user.*` (Home Manager) options. |
| `overlays/` | The framework package layer: `<attr>/package.nix` and/or `<attr>/*.patch`. It is always applied to every machine and has no options; machines layer their own on top instead. |
| `examples/<host>/` | User space. Each is a standalone machine flake (`andromeda`, `perseus`). |
| `scripts/` | Bootstrap, homestrap, `nix-system` and the `just secrets` module. They read config with `nix eval`, never a JSON file. |

## Commands

```bash
git add -A                                   # flakes only see tracked files; do this before every eval/build
nix flake check --no-build                   # root: evaluates both machines, ISOs, checks
(cd examples/andromeda && nix flake check --no-build)
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
nix build .#nixosConfigurations.<host>.config.system.build.toplevel -o <scratch>/result
nix build --no-link .#checks.x86_64-linux.lib-packages
nix fmt                                      # nixfmt-tree, run before committing
```

- **Refactors must not change output.** Compare the `drvPath` of every host before and after. An identical hash is the proof. If the hash changes, explain why to the user.
- **andromeda cannot fully build yet.** Its `secrets.yaml` has no `password/tester`, and sops-nix validates secret keys at build time. To build everything else, extend the config with `sops.validateSopsFiles = false`:
  `nix build --impure --expr '((builtins.getFlake (toString ./.)).nixosConfigurations.andromeda.extendModules { modules = [ { sops.validateSopsFiles = false; } ]; }).config.system.build.toplevel'`
- **perseus builds fully.**
- **Write build outputs to a scratch directory.** Never leave `result` links in the repo.

## Hard rules

- **Never switch.** Do not run `nixos-rebuild switch`, `nh os switch`, `nix-system switch`, or anything that activates a system. Building is the limit. Switching is the user's call.
- **Do not edit `secrets.yaml` files.** They are sops-encrypted to host or user keys you do not have. If a build needs a new secret key, tell the user which key, which file, and the command (`just secrets host edit` / `just secrets user edit`).
- **Respect the user boundary.** Keep machine-specific content in `examples/<host>/`. Do not put host names, usernames or personal packages in `lib/` or `modules/`.
- **Respect example flake inputs.** An example's `outputs` may only use the `dot-nixos` input, because the root flake passes nothing else. Anything else an example needs must come through the framework.
- **Commit on the current branch only.** Branch first if on `main`.

## Pitfalls already hit (and how the design avoids them)

These are evaluation-order traps. Re-introducing any of them shows up as `infinite recursion encountered` or a conflicting definition.

- **`pkgs` must not depend on Home Manager.** System halves auto-enable from `config.home-manager.users.<u>.modules.<name>.enable`, and Home Manager needs the system `pkgs` to build its module list. Anything under the enable guard that feeds `nixpkgs.*` therefore creates a cycle. Unfree allowlists go in the module's top-level `allowUnfree = [ ... ]`, which `defineModule` applies unconditionally, never in `configs.nixpkgs.config`.
- **Option declarations must not depend on `config`.** For example, `modules.open.*` options are generated from the static `modules/open/mime.nix`, not from an option value.
- **Per-user values cannot go through `_module.args`.** It is shared across all users, and two users conflict. That is why `peruser.nix` is curried. Machine-wide values are options (`machine.*`); per-user values are Home Manager options (`user.*`).
- **Module functions only receive named arguments from `_module.args`.** Inside `defineModule` modules, `config`, `lib`, `pkgs` and specialArgs (`inputs`, `osConfig` in Home Manager) are available. Name anything else explicitly in the wrapper in `lib/modules.nix`.
- **`useGlobalPkgs` stays `false`.** Home modules set `nixpkgs.config` per user, which global pkgs forbids. Users still inherit the system's `nixpkgs.overlays`.
- **Guard impermanence-only config.** Use `options.environment ? persistence`, not `config.environment ? persistence` (the latter recurses). Impermanence is only imported when `system/persist.nix` exists.

## How to extend

- **New feature module:** create `modules/<name>/home.nix` and/or `system.nix`, each returning `{ options; configs; }` plus optional `imports`, `assertions`, `allowUnfree`, `persist.home`. It is discovered automatically. Persist paths in `system.nix` are relative to home (`config.machine.directories.home.*`).
- **New framework overlay (package or patch):** create `overlays/<attr>/` at the repo root with a `package.nix` (receives `prev` only if it declares it), `*.patch` files, or both. There is no `patches/` directory. It applies to every machine, so check that every host's `drvPath` changes only as intended. Do not add options to configure it. Consumers who need something else write their own overlay.
- **New machine:** copy an example. Required files are `flake.nix`, `secrets.yaml`, `system/default.nix`, `hardware/default.nix`, `hardware/disk.nix` and at least one `users/<name>/home.nix`. To build it from the root, add its name to the list in the root `flake.nix` and a creation rule to `.sops.yaml`.
- **New user:** create `users/<name>/home.nix`. The machine's `secrets.yaml` needs `password/<name>`, which only the user can add.
- **Machine overlay (package or patch):** drop `package.nix` and/or `*.patch` files into `examples/<host>/overlays/<attr>/`. Patches must apply to the exact upstream source and keep upstream tests passing. Generate them with `diff -u` against the unpacked `src`.

## Conventions

- **Comments:** only explain a reason the code cannot show, on one line. A known limitation gets `# shortcut: <limit>, <when to upgrade>`.
- **Nix style:** `nixfmt` style via `nix fmt`. Prefer native NixOS/Home Manager options over new framework options. Add a framework option only when no native option exists.
- **Tests:** new non-trivial `lib/` logic gets a fixture-based check in `tests/`, wired into `checks` in `flake.nix`. Confirm the check fails when the logic is broken.
