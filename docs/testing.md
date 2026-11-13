# Testing

How the framework is tested, what is still missing, and how a change (by a
person or an agent) is verified before it is committed.

## Running the tests

```bash
git add -A            # flakes only see tracked files
just verify           # formatting and every flake check, about 40 seconds
just verify build     # also builds both examples
nix build --no-link -L .#checks.x86_64-linux.<name>   # one check, with its output
```

| Check | File | What it covers |
|-------|------|----------------|
| `lib` | `tests/lib.nix` | Every helper merged into `lib` |
| `modules` | `tests/modules.nix` | `defineModule`, the module format |
| `machines` | `tests/machines.nix` | `mkMachine`, core and the per-user wiring, through fixture machines |
| `script-secrets`, `script-homestrap`, `script-nix-system`, `script-bootstrap`, `script-iso-bootstrap` | `tests/scripts.nix`, `tests/scripts/*.sh` | The scripts, run for real with faked commands |
| `shellcheck` | `flake.nix` | Every script and script test |
| `options-doc` | `lib/options-doc.nix` | `docs/options.md` matches the option declarations (`just docs` regenerates it) |
| (evaluation) | `nix flake check` | Both examples and both ISOs evaluate |

## How the tests are built

### Unit tests for Nix code

`tests/harness.nix` runs `lib.debug.runTests` cases (attributes named
`test*`, each `{ expr; expected; }`). On failure it stops evaluation with every
failing case and its expected and actual value:

```
error: lib: 1 of 20 failed
  testOutermostPathsSharedPrefixIsNotNesting
    expected: [ "media" "media2" "a/b" "a/bc" ]
    actual:   [ "media" "a/b" ]
```

`tests/lib.nix` tests the helpers directly: `mapAttrNames`, `subdirs`,
`outermostPaths`, the overlay builder (package only, patches only in name
order, both, neither, missing directory) and module discovery. Logic that is
pure but used inside a module, such as the persistence filter, lives in
`lib/` so it can be tested this way.

`tests/modules.nix` evaluates `defineModule` with `lib.evalModules` and
small stand-ins for the NixOS options it writes to, instead of all of NixOS.
It covers the enable option, fields, the enable guard for `configs` and
`extraConfigs`, `imports` and `allowUnfree` outside the guard, assertions,
`persist.home`, `persist.system` with and without impermanence, core, and
home halves.

### Fixture machines

`tests/machines/basic` and `tests/machines/impermanent` are small machines
with virtual hardware (a disk at `/dev/vda`, systemd-boot) and placeholder
secrets files, built by the real `mkMachine` the way a consumer's flake
does. `tests/machines.nix` checks what the framework derives from their files:
the output name, accounts and their defaults, login shells and the programs
they need, password and Wi-Fi secrets, network profiles, the sops host key
path with and without impermanence, system halves following users (and not
settable from the machine), system-only modules, home halves per user, machine overlays reaching users,
user secrets files, the git identity, XDG directories, installed commands,
the persisted paths per user, and that both fixtures evaluate to whole
systems (which also runs every NixOS assertion).

Error cases use copies of `basic` with one file removed
(`builtins.path` with a filter), plus a control copy that has to evaluate,
so an error test cannot pass for the wrong reason.

### Script tests

`tests/scripts.nix` runs each script in the build sandbox. The test in
`tests/scripts/<name>.sh` sources `helpers.sh`, which provides assertions
(`assert_eq`, `assert_contains`, `assert_mode`, `expect_fail`) and `fake
<command> <body>`, a script placed on `PATH` ahead of the real command. Real
tools run wherever the sandbox allows it: sops, age keys, ssh-keygen, git with
local repositories. Only what needs root, a disk or a network is faked:
`sudo`, `nixos-rebuild`, disko, `nixos-install`, `nixos-enter`, `su`.

Two small refactors made the scripts testable: `nixos-bootstrap` takes its
mount point from `NIXOS_BOOTSTRAP_MOUNT` (default `/mnt`), and the ISO's
bootstrap script is a function of its values and commands
(`lib/iso-bootstrap.nix`).

## What the tests found

Writing the tests surfaced these, all fixed:

| Problem | Found by |
|---------|----------|
| Setting one key of `machine.directories.home` or `user.directories` dropped every other directory | Fixture `impermanent`, which moves `pictures` |
| A missing `secrets.yaml` or `users/<name>/home.nix` was only noticed late, when sops or Home Manager read it; `mkMachine` now checks all required files when called | Error cases in `machines` |
| `just flash` failed for key commands containing `$` or backticks, because shellcheck rejected the literal values in the ISO script | `script-iso-bootstrap` |
| The impermanence guard failed when no `environment` option existed at all (not reachable in NixOS, but fragile) | `modules` |

Earlier manual verification in the same style found that `nix system build`
called a command that does not exist and that `nix system <action>` ignored
the flake.

## Verifying a change

1. Before changing anything, run `just verify` to know the starting state.
2. Make the change, `git add -A`, and run `just verify`. A failure names the
   check and prints expected and actual values.
3. When adding logic, add a case that covers it, then break the logic on
   purpose once and confirm a check fails (CLAUDE.md asks for this). A test
   that crashes instead of failing hides every other result, so give lookups
   a fallback value.
4. For pure refactors, also compare each example's `drvPath` before and
   after; they must be identical.
5. Run `just verify build` before committing anything that changes packages,
   modules or scripts.

## Still missing

Each of these is an open issue in [issues.md](issues.md) (25 to 30) and part
of the roadmap's first milestone.

### Snapshots of the examples

Exact `drvPath` comparison proves a refactor changed nothing, but it is
useless once anything changes on purpose, and it changes on every nixpkgs
bump. The plan: `tests/snapshots/<host>.json` with a readable projection of
each example (system packages, enabled services, users with groups and
shells, every user's Home Manager packages and session variables, persisted
paths, generated config files), a check that fails on any difference with a
diff, and `just snapshot update` to accept an intended change as a reviewable
JSON diff.

### Module matrix

One fixture machine per module with only that module enabled, evaluated as a
whole system. It catches modules that silently depend on another (like
`hyprland` needing `theme` before it enabled it itself) and system halves that
break machines lacking something. Each evaluation takes seconds, so twenty of
them belong in `just verify build` rather than the fast tier.

### VM tests

NixOS VM tests (`pkgs.testers.runNixOSTest`) that boot the fixtures with
throwaway keys committed under `tests/keys/`: log in with the passwords from
sops, check `/run/secrets`, every user's Home Manager service, user secrets
(`git config user.name` from the secrets file), NetworkManager profiles,
`nixos-secrets backup` with real sudo, and for `impermanent`, that persisted
files survive a reboot and others do not. The examples can boot the same way
with test keys swapped in and their NVIDIA hardware removed via
`extendModules`.

### Install test

The whole flow in VMs, the way nixpkgs tests its installer: an installer VM
with an empty disk and the target closure preloaded, the fixture repository
served from the test, `nixos-bootstrap` formatting the disk and installing,
then a second boot that runs `nixos-homestrap` and repeats the VM checks. Each
example's disk layout can also get disko's own, much cheaper, test
(`makeDiskoTest`).

### CI

GitHub Actions running `just verify` on every push and the VM tests nightly,
with a binary cache so unchanged derivations are not rebuilt.

## Coverage

Nix has no line coverage tool, so coverage is tracked by feature:

| Feature | Covered by | Not yet |
|---------|------------|---------|
| `lib/` helpers | `lib` | |
| Module format | `modules` | Home-half assertions (not supported yet) |
| `mkMachine` conventions and errors | `machines` | Error messages (only failure is checked) |
| Accounts, shells, passwords | `machines` | Logging in (VM) |
| Secrets and Wi-Fi | `machines`, `script-secrets` | Decryption at boot (VM) |
| Persistence | `machines` | Surviving a reboot (VM) |
| System halves from users | `machines` | Every module alone (matrix) |
| Overlays and patches | `lib`, `machines` | |
| Scripts | `script-*`, `shellcheck` | `open.sh` behaviour |
| Feature modules' behaviour | Examples evaluate and build | Snapshots, VM |
| Disk layouts and installation | `script-bootstrap` with fakes | Real disks (VM) |
