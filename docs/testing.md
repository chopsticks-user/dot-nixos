# Testing

How the framework is tested today, how it should be tested to cover nearly
every feature, and how a change (by a person or an agent) gets verified before
it is committed.

## Today

| What | How | Gap |
|------|-----|-----|
| Overlay and patch helpers | `checks.<system>.lib-packages`: fixture overlays evaluated against nixpkgs with assertions | Only `mkOverlaysFrom` is covered |
| Machines evaluate | `nix flake check --no-build` evaluates both examples and the ISOs | Evaluating proves nothing about behaviour |
| Refactors | Comparing each host's `drvPath` before and after, by hand | Manual; any intended change makes the hash useless as evidence |
| Installed scripts | Built with `writeShellApplication`, which runs shellcheck | Never executed; `bootstrap.sh` has never run in a test |
| Everything else | Building the examples by hand | No boot, no secrets, no login, no install |

During the MVP work, changes were verified by hand with the techniques the
plan below automates: diffing evaluated values (package names, session
variables, persisted paths, generated configs) against the previous commit,
running scripts in a scratch directory with fake commands on `PATH`, and
building both machines. Those checks found two real bugs (`nix system build`
calling a command that does not exist, and `nix system <action>` ignoring the
flake) that evaluation alone had missed.

## Layers

Seven layers, from milliseconds to tens of minutes. Each layer catches what
the cheaper ones cannot.

### 1. Static checks

`nix fmt` in check mode, shellcheck on every script in `scripts/` (not only
the installed ones), and optionally `deadnix` and `statix` for unused bindings
and anti-patterns. All as flake checks, so `nix flake check` fails on them.

### 2. Library tests

Pure evaluation tests for everything in `lib/`, written with
`lib.debug.runTests` so a failure prints the expected and actual values
instead of a bare assertion:

| Helper | Cases |
|--------|-------|
| `mkOverlaysFrom` | Package only, patches only, both, neither (throws), name order and `prev`, `prev` only when declared, non-patch files ignored (exists today as fixtures) |
| `subdirs`, `mapAttrNames` | Missing directory, files ignored, renaming |
| `defineModule` | `enable` added except for core; `configs` only under the guard; `allowUnfree` applied with the module off; `persist.home` recorded per module; `persist.system` ignored without impermanence and applied with it; assertions guarded by enable |
| `moduleNamesWith` | Modules with one or both halves |

`defineModule` is tested through `lib.evalModules` with small stub option
declarations (`nixpkgs.config.allowUnfreePackages`,
`environment.persistence`), so the tests stay independent of NixOS.

### 3. Machine evaluation tests

Small fixture machines under `tests/machines/`, built with `mkMachine` exactly
like a consumer's. They use virtual hardware (no nixos-hardware, a disk at
`/dev/vda`) and throwaway keys committed under `tests/keys/`, clearly marked
as insecure and used for nothing else.

| Fixture | Exercises |
|---------|-----------|
| `minimal` | One user, no optional files: required files, defaults, core only |
| `two-users` | Different shells and modules per user: system halves enabled from either user, `programs.<shell>` enabled, account fields read back |
| `impermanent` | `system/persist.nix` and user `persist.nix`: sops key path under `/persist`, core, module and user persistence lists merged without duplicates, nested data directories filtered |
| `overlays` | Machine overlays and patches layered on the framework layer |
| `broken-*` | Missing required file, user without `home.nix`, overlay directory with neither file: evaluation fails with the intended message (`builtins.tryEval` plus a message check) |

Each fixture has an `expected.nix` of assertions on evaluated values: who the
users are, their shells and groups, which modules are on, the persisted paths,
`sops.age.sshKeyPaths`, the values baked into `scriptEnv`, which packages are
installed. These are the facts this round's manual diffs checked.

A module matrix generates one machine per module with only that module
enabled and evaluates it. This catches modules that silently depend on
another (like `hyprland` needing `theme` before it enabled it itself) and
modules whose system half breaks machines that lack something.

### 4. Snapshots of the examples

Exact `drvPath` comparison proves a refactor changed nothing, but it is
useless once anything changes on purpose, and it changes on every nixpkgs
bump. Snapshots keep the evidence readable instead:

- `tests/snapshots/<host>.json` holds a curated, human-readable projection of
  each example: system package names, enabled services, users with their
  groups and shells, every user's Home Manager package names and session
  variables, persisted paths, generated config files' store names, overlay
  results.
- A check evaluates the projection and fails on any difference, printing a
  diff.
- `just snapshot update` rewrites them. An intended change then shows up in
  the commit as a reviewable JSON diff ("frost lost `coreutils`, gained
  nothing"), and an unintended one fails the check.

`drvPath` comparison stays for pure refactors, where an identical hash is
still the strongest proof.

### 5. Script tests

Run the scripts for real inside a check derivation, with the outside world
faked on `PATH`:

| Script | Fakes | Asserts |
|--------|-------|---------|
| `nixos-secrets` | `sudo` that runs its arguments, test keys, a temporary repository with `.sops.yaml` | `new` writes an archive of mode 600 with the expected members and refuses to overwrite; `host` and `user` `edit` create and decrypt; `update` re-encrypts after a recipient is added; `backup` includes every user that has a key and warns for the rest |
| `nixos-homestrap` | A local git repository, a key command that `cat`s a test key | Clone, key and public key with the right modes; a second run changes nothing and does not run the key command |
| `nix-system` | `nixos-rebuild`, `nvd` and `nix` that record their arguments | Every action gets `--flake <dir>#<host>`; `switch` asks before switching |
| `nixos-bootstrap` | `git`, `nix`, `sudo`, `nixos-install` and disko recording their arguments; the mount point taken from an environment variable defaulting to `/mnt` | The host key lands at the evaluated sops path under the mount point, with the right modes; the host check rejects a missing host |
| ISO `bootstrap` | Values passed as function arguments instead of `builtins.getEnv`, so the test is pure | Quotes and spaces in key commands survive into both calls |

Two small refactors make this possible: a mount point variable in
`bootstrap.sh`, and `lib/iso.nix` taking its baked values as arguments (with
`just flash` passing the environment).

### 6. VM tests

NixOS VM tests (`pkgs.testers.runNixOSTest`) boot real machines in QEMU:

| Test | Machine | Checks |
|------|---------|--------|
| `boot` | `two-users` fixture | Root and user passwords from sops (log in with them), `/run/secrets` populated, every user's Home Manager service succeeded, user secrets decrypted (`git config user.name` comes from the secrets file), NetworkManager profiles present, the installed commands run |
| `impermanence` | `impermanent` fixture | Files in persisted paths survive a reboot (`machine.shutdown()`, `machine.start()`) and files elsewhere do not; the host key is read from `/persist` |
| `examples` | Both examples with test keys swapped in and NVIDIA hardware removed via `extendModules` | They boot to a login, Hyprland's session starts for a user |
| `secrets` | `two-users` | `nixos-secrets backup` with real sudo, `host public` matches `.sops.yaml` |

### 7. Install tests

The whole install flow in VMs, the way nixpkgs tests its installer:

1. An installer VM built from `lib/iso.nix`, with an empty second disk and
   the target system's closure preloaded (`virtualisation.additionalPaths`),
   so no network is needed.
2. The fixture machine's repository served from the test (a `file://` URL or
   `git daemon`), and key commands that `cat` the test keys.
3. `nixos-bootstrap` runs: disko formats the empty disk (answering its
   confirmation), the host key lands where sops reads it, `nixos-install`
   finishes.
4. A second VM boots from that disk, runs `nixos-homestrap`, reboots, and
   repeats the checks of the `boot` test.

Each example's disko layout also gets disko's own test
(`makeDiskoTest`, with the device pointed at the VM disk), which is much
cheaper than a full install.

## Coverage map

| Feature | Layers |
|---------|--------|
| `mkMachine` conventions and errors | 3 |
| System halves enabled from users | 3, 6 |
| Overlays and patches | 2, 3, 4 |
| Persistence (core, modules, users) | 3, 6 |
| Secrets (host, users, Wi-Fi, git identity) | 3, 5, 6 |
| Accounts and shells | 3, 6 |
| Every module evaluates alone | 3 (matrix) |
| Module behaviour (desktop, editors, gaming) | 4 (snapshots), 6 (examples boot) |
| Scripts | 1, 5, 6, 7 |
| Disk layouts | 7 (disko tests) |
| Install flow | 7 |
| Refactors | 4 (snapshots), `drvPath` comparison |

What stays untested: real hardware (GPU drivers, firmware), the desktop
beyond starting, and network installs against a real Git host. Those remain
manual, before releases.

## Verifying a change

One entry point, in three tiers, so the cheap checks run on every change and
the expensive ones before merging:

| Command | Runs | Time |
|---------|------|------|
| `just verify` | Layers 1 to 4: formatting, shellcheck, library tests, machine fixtures and the module matrix, snapshots | About a minute |
| `just verify build` | Adds layer 5 and builds both examples | Minutes |
| `just verify full` | Adds layers 6 and 7 | Tens of minutes, KVM needed |

The workflow for an agent (and for anyone):

1. Before changing anything, run `just verify` to know the starting state.
2. Make the change and run `just verify`. A failure points at the layer and
   prints the expected and actual values.
3. If snapshots changed on purpose, run `just snapshot update` and read the
   diff: every line should be explained by the change. Anything unexplained is
   a bug.
4. For pure refactors, also compare `drvPath`s; they must be identical.
5. Run `just verify build` before committing anything that touches scripts,
   packages or modules; `just verify full` before merging to `main`.
6. When adding logic, break it on purpose once and confirm a check fails
   (CLAUDE.md asks for this), then restore it.

CI runs `just verify build` on every push and `just verify full` nightly and
on pull requests, with a binary cache so unchanged derivations are not
rebuilt.

## Order of work

Each step is useful on its own:

1. Static checks and the `verify` entry point (small, immediate).
2. Snapshots of the examples (the biggest gain for reviewing changes).
3. Library tests for `defineModule`.
4. Test keys, fixture machines, the module matrix.
5. Script tests, with the two small refactors they need.
6. VM tests, then the install test.

Steps 1 to 3 are listed in [backlog.md](backlog.md); the rest belong to the
roadmap's first milestone.
