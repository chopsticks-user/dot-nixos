# CLAUDE.md

@README.md

The README above says what the framework is. `docs/guide.md` is the source of
truth for how it is used and `docs/options.md` (generated) for its options.
This file only adds what an agent needs to work in the repo safely. When the
user-facing design changes, update the guide, not this file.

## Where things live

| Path | What it is |
|------|------------|
| `flake.nix` | Framework flake: `lib.mkMachine`, `checks`, `formatter`, ISOs. It also exposes each example's `nixosConfigurations` by calling the example's `outputs { dot-nixos = self; }`. |
| `lib/mk-machine.nix` | The builder. Reads the machine directory, wires embedded Home Manager, and is the only writer of the read-only `enable` of system halves. |
| `lib/modules.nix` | `defineModule`, plus discovery of `modules/*/system.nix` and `modules/*/home.nix`. |
| `lib/overlays.nix` | The only place that writes `nixpkgs.overlays`: flake-input overlays (`llm-agents`) and the framework's `overlays/` (always on), then the machine's on top. |
| `lib/peruser.nix` | System side of one user: account, password secret, per-user persistence. Curried with `{ username, userPersist }`. |
| `lib/packages.nix`, `lib/attrs.nix`, `lib/paths.nix` | Helpers merged into `lib`. `lib/default.nix` lists helper files explicitly, so a new helper file must be added there. |
| `tests/` | Flake checks. `harness.nix` runs `lib.debug.runTests` cases and reports expected and actual values; `lib.nix` unit-tests the `lib/` helpers with fixtures (`checks.<system>.lib`). |
| `modules/<name>/` | Feature modules. `system.nix` is the NixOS half and `home.nix` the Home Manager half, both under the `modules.<name>` namespace. |
| `modules/core/` | Always-on module. It declares `machine.*`, `persist.home` (NixOS) and `user.*` (Home Manager) options. Keep it to what every machine needs; personal defaults belong in opt-in modules such as `cli` and `theme`. |
| `overlays/` | The framework package layer: `<attr>/package.nix` and/or `<attr>/*.patch`. It is always applied to every machine and has no options; machines layer their own on top instead. |
| `examples/<host>/` | User space. Each is a standalone machine flake (`andromeda`, `perseus`). |
| `scripts/` | `bootstrap.sh` (installer), `homestrap.sh`, `secrets.sh` (`nixos-secrets`), `nix-system.sh`, `open.sh`. Installed scripts get build-time paths from `scriptEnv` in `modules/core/system.nix`; bootstrap reads the machine with `nix eval`. Never a JSON file. |
| `lib/options-doc.nix` | Renders `docs/options.md` from the option declarations of the `basic` fixture; exposed as `packages.<system>.options-doc` and checked by `checks.<system>.options-doc`. |
| `docs/` | The documents described in "Documents" below. |

## Commands

```bash
git add -A                                   # flakes only see tracked files; do this before every eval/build
nix flake check --no-build                   # root: evaluates both machines, ISOs, checks
(cd examples/andromeda && nix flake check --no-build)
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
nix build .#nixosConfigurations.<host>.config.system.build.toplevel -o <scratch>/result
nix build --no-link .#checks.x86_64-linux.lib
nix fmt                                      # nixfmt-tree, run before committing
just docs                                    # regenerate docs/options.md after changing any option
nix shell nixpkgs#shellcheck -c shellcheck -s bash scripts/*.sh   # installed scripts are built with writeShellApplication, which fails on any finding
```

- **Refactors must not change output.** Compare the `drvPath` of every host before and after. An identical hash is the proof. If the hash changes, explain why to the user.
- **andromeda cannot fully build yet.** Its `secrets.yaml` has no `password/tester`, and sops-nix validates secret keys at build time. To build everything else, extend the config with `sops.validateSopsFiles = false`:
  `nix build --impure --expr '((builtins.getFlake (toString ./.)).nixosConfigurations.andromeda.extendModules { modules = [ { sops.validateSopsFiles = false; } ]; }).config.system.build.toplevel'`
- **perseus builds fully.**
- **Write build outputs to a scratch directory.** Never leave `result` links in the repo.

## Hard rules

- **Never switch.** Do not run `nixos-rebuild switch`, `nh os switch`, `nix-system switch`, or anything that activates a system. Building is the limit. Switching is the user's call.
- **Do not edit `secrets.yaml` files.** They are sops-encrypted to host or user keys you do not have. If a build needs a new secret key, tell the user which key, which file, and the command (`nixos-secrets host edit [<machine-dir>]` / `nixos-secrets user edit [<machine-dir>]`).
- **Respect the user boundary.** Keep machine-specific content in `examples/<host>/`. Do not put host names, usernames or personal packages in `lib/` or `modules/`.
- **Respect example flake inputs.** An example's `outputs` may only use the `dot-nixos` input, because the root flake passes nothing else. Anything else an example needs must come through the framework.
- **Work goes through GitHub, based on `demo`.** Follow the issue, branch, pull request, review workflow from the global instructions. Branch off `demo` and open pull requests against `demo`, not `main` (`main` is the old configuration until `demo` replaces it).

## Pitfalls already hit (and how the design avoids them)

These are evaluation-order traps. Re-introducing any of them shows up as `infinite recursion encountered` or a conflicting definition.

- **`pkgs` must not depend on Home Manager.** System halves auto-enable from `config.home-manager.users.<u>.modules.<name>.enable`, and Home Manager needs the system `pkgs` to build its module list. Anything under the enable guard that feeds `nixpkgs.*` therefore creates a cycle. Unfree allowlists go in the module's top-level `allowUnfree = [ ... ]`, which `defineModule` applies unconditionally, never in `configs.nixpkgs.config`. Reading a Home Manager *value* into a `nixpkgs.config` list is fine (mk-machine does it for `user.allowUnfree`, and it is only forced when a license is checked); making whether `nixpkgs.*` is defined depend on Home Manager is not.
- **Option declarations must not depend on `config`.** For example, `modules.open.*` options are generated from the static `modules/open/mime.nix`, not from an option value.
- **Per-user values cannot go through `_module.args`.** It is shared across all users, and two users conflict. That is why `peruser.nix` is curried. Machine-wide values are options (`machine.*`); per-user values are Home Manager options (`user.*`).
- **Module functions only receive named arguments from `_module.args`.** Inside `defineModule` modules, `config`, `lib`, `pkgs` and specialArgs (`inputs`, `osConfig` in Home Manager) are available. Name anything else explicitly in the wrapper in `lib/modules.nix`.
- **`useGlobalPkgs` is `true`.** Users share the system's nixpkgs and overlays. Home halves and `home.nix` must not set `nixpkgs.*` (Home Manager asserts); they add unfree names to `user.allowUnfree`, and a home half must not use top-level `allowUnfree`.
- **Guard impermanence-only config.** Use `options ? environment.persistence`, not `config.environment ? persistence` (the latter recurses). Impermanence is only imported when `system/persist.nix` exists.

## How to extend

- **New feature module:** create `modules/<name>/home.nix` and/or `system.nix`, each returning `{ options; configs; }` plus optional `imports`, `assertions`, `allowUnfree` (system halves only), `persist.home` and `persist.system`. It is discovered automatically. Persist paths are declared in `system.nix`: `persist.home` is relative to home and applies only to users who enable the module (to everyone for modules without a home half); `persist.system` applies only under impermanence.
- **New or changed option:** give it a `description` (and `defaultText` when the default is computed or holds packages), then run `just docs`. The `options-doc` check fails until `docs/options.md` matches.
- **New framework overlay (package or patch):** create `overlays/<attr>/` at the repo root with a `package.nix` (receives `prev` only if it declares it), `*.patch` files, or both. There is no `patches/` directory. It applies to every machine, so check that every host's `drvPath` changes only as intended. Do not add options to configure it. Consumers who need something else write their own overlay.
- **New machine:** copy an example. Required files are `flake.nix`, `secrets.yaml`, `system/default.nix`, `hardware/default.nix`, `hardware/disk.nix` and at least one `users/<name>/home.nix`. To build it from the root, add its name to the list in the root `flake.nix` and a creation rule to `.sops.yaml`.
- **New user:** create `users/<name>/home.nix`. The machine's `secrets.yaml` needs `password/<name>`, which only the user can add.
- **New installed script:** add `scripts/<name>.sh` and install it with the `script` helper in `modules/core/system.nix`, listing its runtime inputs. Values it needs from the configuration go into `scriptEnv`, not `nix eval` at runtime.
- **Machine overlay (package or patch):** drop `package.nix` and/or `*.patch` files into `examples/<host>/overlays/<attr>/`. Patches must apply to the exact upstream source and keep upstream tests passing. Generate them with `diff -u` against the unpacked `src`.

## Conventions

- **Comments:** only explain a reason the code cannot show, on one line. A known limitation gets `# shortcut: <limit>, <when to upgrade>`.
- **Nix style:** `nixfmt` style via `nix fmt`. Prefer native NixOS/Home Manager options over new framework options. Add a framework option only when no native option exists.
- **Tests:** new non-trivial logic gets a test: pure helpers in `tests/lib.nix` (move logic into `lib/` if it hides in a module), the module format in `tests/modules.nix`, anything `mkMachine` or core derives in `tests/machines.nix` against the fixtures in `tests/machines/`, scripts in `tests/scripts/`. Break the logic once and confirm a check fails. Run `just verify` before and after a change. See `docs/testing.md`.

## Documents

Each file in `docs/` has one job. Open problems and planned work are GitHub issues, and finished work is a merged pull request; neither is kept in `docs/`.

| File | What it is | Update it when |
|------|------------|----------------|
| `README.md` | Overview: what the framework is, how a machine flake starts, the examples, a short "how it works" with links into the guide, the philosophy, and the index of these documents. It holds no reference material of its own | The pitch, examples or document list change |
| `CLAUDE.md` | This file: what an agent needs on top of the README | Paths, commands, rules or pitfalls change |
| `docs/guide.md` | The consumer guide: creating, installing and operating a machine, and the reference of every module and command. Option details live in `options.md` | Any module, command, file convention or install step changes |
| `docs/options.md` | Generated option reference; never edit by hand | Any option changes: run `just docs` |
| `docs/design.md` | Every design decision, numbered, with why, cost and a recommendation (keep, improve, decide) | A decision is made, reversed or its cost changes |
| `docs/roadmap.md` | Long-term goals: milestones toward a NixOS machine generator | Goals or milestones change |
| `docs/testing.md` | How to run the tests, what each check covers, how they are built, what is still missing, and coverage by feature | Tests are added or the plan changes |

## GitHub

- **Labels:** `bug`, `security`, `enhancement`, `tests`, `documentation`, `needs-owner` (cannot be done from the repository alone).
- **Pull requests** follow `.github/pull_request_template.md` (Why, Changes, Verification, Notes) and start with `Closes #<n>`. Verification names the checks run and whether every host's `drvPath` changed.
- **Each commit message stays self-contained**; the pull request summarises the commits of one task.
- **Links to issues from `docs/`** are full URLs (`https://github.com/chopsticks-user/dot-nixos/issues/<n>`); Markdown files do not auto-link `#<n>`.
