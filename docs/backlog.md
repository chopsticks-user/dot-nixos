# Backlog

The coding log. Every finished change is recorded here as a pull request:
why it was needed, what changed, how it was verified, and its commits. Open
problems and planned work are issues in [issues.md](issues.md); larger goals
are in [roadmap.md](roadmap.md).

All pull requests so far were merged into `demo`. PRs 1 to 10 were logged after
the fact from their commit messages.

## Index

| PR | Title | Merged | Commits |
|----|-------|--------|---------|
| 33 | Persist what every machine needs in core | 2026-11-13 | this entry's commit |
| 32 | Turn the backlog into a coding log and record each doc's role | 2026-11-12 | this entry's commit |
| 31 | Add an issue tracker and document the test suite | 2026-11-12 | `bc507f1` |
| 30 | Add `just verify` and a shellcheck check for every script | 2026-11-12 | `b574bbb` |
| 29 | Run the scripts in the sandbox with faked commands | 2026-11-12 | `1bccfa4` |
| 28 | Make the bootstrap mount point and the ISO script testable | 2026-11-12 | `0180544` |
| 27 | Test `mkMachine` through fixture machines | 2026-11-12 | `d047444` |
| 26 | Let each well-known directory be overridden on its own | 2026-11-12 | `315b5c9` |
| 25 | Unit-test `defineModule` | 2026-11-12 | `d180cee` |
| 24 | Unit-test every lib helper through a reporting harness | 2026-11-12 | `abe25ba` |
| 23 | Mark the literal `$op` placeholder in `open.sh` | 2026-11-12 | `4297f5c` |
| 22 | Consumer guide, design decisions, test plan, roadmap | 2026-11-12 | `d078a48`, `588d175`, `9c45e62`, `68aac48` |
| 21 | Pass the machine flake to every `nix system` action | 2026-11-12 | `8af165d` |
| 20 | Empty the framework overlay layer, drop caelestia | 2026-11-12 | `a497877` |
| 19 | Make modules work on machines other than the original two | 2026-11-12 | `a61f2d4` |
| 18 | Move personal settings from modules into the example users | 2026-11-12 | `267ffaa` |
| 17 | Replace the firefox profile dump with chosen preferences | 2026-11-12 | `d121f03` |
| 16 | Install machines from their own repository | 2026-11-12 | `6e58e1d` |
| 15 | Replace the just secrets module with `nixos-secrets` | 2026-11-12 | `91c20e7` |
| 14 | Keep only framework essentials in the core module | 2026-11-12 | `5578f53` |
| 13 | Fix `nix system build`, OBS `global.ini` and swapped MIME types | 2026-11-12 | `9ae615a` |
| 12 | Overlay llm-agents packages into nixpkgs | 2026-11-12 | `5df4079` |
| 11 | Fold patches into overlays | 2026-11-12 | `550b26b` |
| 10 | Move tests to the repository root | 2026-11-11 | `607781b` |
| 9 | Add CLAUDE.md | 2026-11-11 | `0de2d19` |
| 8 | Make framework overlays always-on policy | 2026-11-11 | `54ea4b5` |
| 7 | Pick up machine overlays and patches by convention | 2026-11-11 | `40dfc04`, `1ca3625` |
| 6 | Move flake templates into the andromeda example | 2026-11-11 | `62ca4c4` |
| 5 | Add the perseus example | 2026-11-11 | `214b6c9` |
| 4 | Make examples standalone machine flakes | 2026-11-11 | `4e79f2f` |
| 3 | Group machine files under `hardware/` and `system/` | 2026-11-11 | `664ceba`, `c75dea1`, `ce1f42a` |
| 2 | Rename features to modules, fold internals into `lib/` | 2026-11-11 | `c6298d2` |
| 1 | Turn the repository into a single-machine, multi-user framework | 2026-11-11 | `fdcc2f4` |

## PR 33: Persist what every machine needs in core

2026-11-13 · Commits: the commit that adds this entry

**Why.** Every impermanent machine repeated the same system list (NixOS
state, machine id, logs, NetworkManager, sops, the host key), and every user
repeated the same home list for state the framework itself creates (nix and
Home Manager state, user secrets). The two tester `persist.nix` files were
identical.

**Changes.** Core's system half gains `persist.system` with the NixOS and
core-service paths plus the directory of `machine.directories.identity`, and
its `persist.home` gains `.config/sops-nix`, `.local/state/nix`,
`.local/state/home-manager` and `.cache/nix`. perseus's `system/persist.nix`
keeps only bluetooth and seanime; the tester files and the impermanent
fixture drop what core now covers. Per-user module persistence is unchanged:
a module's home paths still apply only to users who enable it.

**Verification.** `just verify` passes; the machine tests expect the new
lists. The sorted persisted paths of perseus are identical before and after;
its `drvPath` changes only because the list order changed. andromeda's
`drvPath` is unchanged.

## PR 32: Turn the backlog into a coding log and record each doc's role

2026-11-12 · Commits: the commit that adds this entry

**Why.** The backlog mixed finished work with open tasks. The owner wants it
to work like a pull request log, with open work in a separate issue tracker
(PR 31), and wants the role of each document recorded so agents keep them
apart.

**Changes.** This file is rewritten as one entry per pull request, from
PR 1 on. CLAUDE.md gets a section describing each document and when to update
it; the README's document table matches it.

**Verification.** Links between the docs resolve; no em dashes.

## PR 31: Add an issue tracker and document the test suite

2026-11-12 · Commits `bc507f1` · Opens issues 5 to 32, records 1 to 4 as closed

**Why.** Problems found by the tests and planned work had no place except the
backlog, and `testing.md` still described the suite as a plan.

**Changes.** `docs/issues.md` with an index and one entry per issue: the four
bugs the test suite found (closed) and the open items that need the owner,
known problems and planned work. `docs/testing.md` rewritten for the suite as
it exists: how to run it, what each check covers, how the harness, fixtures
and script tests are built, what the tests found, how to verify a change,
what is missing, and coverage by feature. Other docs point open work at
`issues.md`.

**Verification.** Links resolve; every closed issue names the commit that
fixed it.

## PR 30: Add `just verify` and a shellcheck check for every script

2026-11-12 · Commits `b574bbb`

**Why.** One command should tell a person or an agent whether a change is
good; and only installed scripts were shellchecked, at build time.

**Changes.** `just verify` runs `nix fmt -- --ci` and `nix flake check`;
`just verify build` also builds both examples (andromeda with sops validation
off, issue 5). A `shellcheck` flake check covers every script in `scripts/`
and the script tests, which brings in `open.sh` and `bootstrap.sh`.

**Verification.** `just verify` passes in about 40 seconds.

## PR 29: Run the scripts in the sandbox with faked commands

2026-11-12 · Commits `1bccfa4`

**Why.** The scripts had only ever been run by hand in scratch directories,
and `bootstrap.sh` never.

**Changes.** `tests/scripts.nix` runs each script in a check derivation, with
`tests/scripts/<name>.sh` asserting on the results and `helpers.sh`
providing assertions and fake commands on `PATH`. Covered: every
`nixos-secrets` subcommand against real sops and keys; homestrap's clone, key
modes, re-runs and failing key commands; `nix-system`'s dispatch and switch
confirmation; bootstrap's host key placement with and without impermanence,
disko and install arguments, and a missing host stopping before any disk;
and the ISO bootstrap carrying hostile key commands unchanged through two
rounds of quoting. Checks are named `script-<name>`.

**Verification.** All five pass. Removing the never-overwrite guard from
`nixos-secrets` and the `%q` quoting from the ISO script each made their
test fail. Shellcheck passes on the tests.

**Notes.** Writing the secrets test showed its usage checks first passed for
the wrong reason (an unbound variable); they now check for the usage text.

## PR 28: Make the bootstrap mount point and the ISO script testable

2026-11-12 · Commits `0180544` · Closes issue 4

**Why.** The script tests (PR 29) need to run bootstrap against a scratch
mount point, and to build the ISO's bootstrap script with chosen values and
fake commands.

**Changes.** `nixos-bootstrap` takes `NIXOS_BOOTSTRAP_MOUNT` (default
`/mnt`) and passes it to disko, `nixos-generate-config` and `nixos-install`.
The ISO's script moves to `lib/iso-bootstrap.nix`, a `callPackage`
function of its values and commands. Shellcheck's SC2016 is excluded for it,
which fixes issue 4.

**Verification.** With the same values the ISO script builds the same
derivation as before the move.

## PR 27: Test `mkMachine` through fixture machines

2026-11-12 · Commits `d047444` · Closes issue 3

**Why.** `mkMachine`, the core module and the per-user wiring had no tests;
their behaviour was checked by diffing the examples by hand.

**Changes.** `tests/machines/basic` and `tests/machines/impermanent`, small
machines with virtual hardware, and `tests/machines.nix` with 36 checks on
what the framework derives from their files, plus error cases built from
copies of `basic` with one file removed and a control copy. `mkMachine` now
checks every required file and each user's `home.nix` when called.

**Verification.** All 36 pass in about 12 seconds. Disabling the per-user
shell enabling failed the check through NixOS's own assertion; dropping the
user key directory from core's persisted paths failed three cases. Both
examples evaluate to the same `drvPath` as before.

**Notes.** A lookup in one case crashed instead of failing when the
persisted path was missing, which hid every other result; it now falls back
to a value that fails visibly. The impermanent fixture persists
`/var/lib/nixos`, as the guide recommends, which silenced impermanence's
missing-uid warning.

## PR 26: Let each well-known directory be overridden on its own

2026-11-12 · Commits `315b5c9` · Closes issue 2

**Why.** Setting one key of `machine.directories.home` or `user.directories`
replaced the whole default (issue 2), found while writing the `impermanent`
fixture.

**Changes.** Each key is now its own `mkDefault` definition instead of part of
the option's default.

**Verification.** Overriding `pictures` on perseus keeps all 20 directories,
machine-wide and for the user. Both examples evaluate to the same `drvPath`.

## PR 25: Unit-test `defineModule`

2026-11-12 · Commits `d180cee` · Closes issue 1

**Why.** The module format every feature uses had no tests.

**Changes.** `tests/modules.nix` evaluates `defineModule` with
`lib.evalModules` and stand-ins for the options it writes to: 14 cases for
the enable option, fields, the enable guard, imports and `allowUnfree`
outside it, assertions, `persist.home`, `persist.system` with and without
impermanence, core, and home halves. `defineModule` is exported. The
impermanence guard becomes `options ? environment.persistence` everywhere
(issue 1).

**Verification.** All 14 pass; making every module always on failed the
disabled-module case. Both examples evaluate to the same `drvPath`.

## PR 24: Unit-test every lib helper through a reporting harness

2026-11-12 · Commits `abe25ba`

**Why.** Only the overlay builder had a test, and its assertions failed
without saying what was wrong.

**Changes.** `tests/harness.nix` runs `lib.debug.runTests` cases and reports
each failure with expected and actual values. `tests/lib.nix` replaces
`tests/packages.nix` and covers every helper. The core module's persistence
filter moves to `lib/paths.nix` as `outermostPaths` so it can be tested.

**Verification.** 20 cases pass; changing the filter's prefix check failed the
shared-prefix case with a readable report. Both examples evaluate to the same
`drvPath`.

## PR 23: Mark the literal `$op` placeholder in `open.sh`

2026-11-12 · Commits `4297f5c`

**Why.** Shellcheck flagged `sd '\$op'`, which is single-quoted on purpose.
`open.sh` was never checked because it is installed with
`writeShellScriptBin`.

**Changes.** A shellcheck directive with the reason.

**Verification.** Shellcheck passes on every script.

## PR 22: Consumer guide, design decisions, test plan, roadmap

2026-11-12 · Commits `d078a48`, `588d175`, `9c45e62`, `68aac48`

**Why.** The framework had a README written for its author; consumers had no
guide, and the decisions behind it were not written down.

**Changes.** `docs/guide.md`, the full consumer guide and reference.
`docs/design.md`, 24 decisions with their costs and a recommendation each.
`docs/testing.md`, the test plan. `docs/roadmap.md`, the path to a NixOS
machine generator. The README becomes an overview with a document index;
`docs/backup.md` and the `docs/secrets` skeletons fold into the guide.

**Verification.** Every claim about commands was checked against the code;
this found the bug fixed in PR 21. Links resolve.

## PR 21: Pass the machine flake to every `nix system` action

2026-11-12 · Commits `8af165d`

**Why.** `nix system <action>` ran a bare `nixos-rebuild <action>` for every
action other than build, switch and info, which uses `/etc/nixos`.

**Changes.** The fallthrough adds `--flake <checkout>#<host>`.

**Verification.** Run with a fake `nixos-rebuild` that prints its arguments.

## PR 20: Empty the framework overlay layer, drop caelestia

2026-11-12 · Commits `a497877`

**Why.** The framework's `overlays/` held leftovers: openldap and bottles
evaluated to the exact nixpkgs derivations, and unreal-engine was a personal
package nobody used. The caelestia input had no users.

**Changes.** openldap and bottles removed, unreal-engine moved to andromeda,
caelestia removed from the inputs and from both example locks.

**Verification.** Both machines evaluate to the same `drvPath` as before, from
the root flake and from their own flakes.

## PR 19: Make modules work on machines other than the original two

2026-11-12 · Commits `a61f2d4`

**Why.** Several modules assumed the author's machines: git failed for any
user without a secrets file, virtualization forced the NVIDIA container
toolkit, hyprland always started fcitx5 and its default apps could not be
overridden.

**Changes.** `modules.git.identityFromSecrets` makes the secret-backed
identity opt-in, and the unused `include` option goes; virtualization no
longer sets the NVIDIA toolkit and persists `boxes`; hyprland starts fcitx5
only when configured, sets `modules.open` with `mkDefault`, and drops the
unused caelestia import.

**Verification.** The examples' git config, MIME defaults, container paths and
Hyprland config evaluate unchanged.

## PR 18: Move personal settings from modules into the example users

2026-11-12 · Commits `267ffaa`

**Why.** Framework modules carried one person's settings: Claude plugins and
tools in `llm`, Unreal Editor rules in `hyprland`, an Arch container in
`virtualization`, Japanese, Chinese and Vietnamese input methods in `fcitx`.

**Changes.** Those settings move to frost's `home.nix` and each example's
`system/input-method.nix`; the modules keep the generic part.

**Verification.** frost's packages, Claude settings, containers and session
path evaluate the same; Hyprland gets the same window rules in a different
order.

## PR 17: Replace the firefox profile dump with chosen preferences

2026-11-12 · Commits `d121f03` · Opens issue 7

**Why.** The module was a copy of a live `prefs.js`, including a Firefox Sync
email, sync and telemetry IDs, applied to every user.

**Changes.** Fourteen chosen preferences remain.

**Verification.** Evaluated profile settings checked. Existing profiles keep
their `prefs.js`.

**Notes.** The data remains in git history (issue 7).

## PR 16: Install machines from their own repository

2026-11-12 · Commits `6e58e1d` · Opens issue 6

**Why.** Bootstrap and homestrap cloned this repository and looked the host up
in its root flake, so only the examples could be installed.

**Changes.** Both take the machine repository URL. Bootstrap writes the host
key to the path sops reads, evaluated from the machine; homestrap can be
re-run, writes the key with umask 077, and no longer garbage collects or
wipes `/tmp`. The ISO automation takes the repository URL, escapes its
values, and no longer prompts to reboot inside the chroot.

**Verification.** Shellcheck; homestrap run twice in a scratch directory; the
ISO script built with quoted values. Bootstrap itself was not run (it wipes a
disk) until PR 29 tested it with fakes.

## PR 15: Replace the just secrets module with `nixos-secrets`

2026-11-12 · Commits `91c20e7`

**Why.** The just recipes always targeted andromeda, `update` was empty, and
`new` deleted the keys it generated on exit.

**Changes.** `nixos-secrets` installed on every machine with its paths baked
in: `host` and `user` (`edit`, `public`, `private`) for any machine
directory, `update`, `new` writing an archive that is never overwritten, and
`backup`.

**Verification.** `new`, `edit`, `public` and decryption exercised with a
throwaway `.sops.yaml`; `backup` was not run (it needs sudo) until PR 29.

## PR 14: Keep only framework essentials in the core module

2026-11-12 · Commits `5578f53` · Opens issue 6

**Why.** Core, which is always on, carried personal defaults: a CLI toolkit,
fonts and cursor, a time zone, kitty as terminal.

**Changes.** New `cli` and `theme` modules; zoxide and fzf move to `zsh`; the
time zone becomes native; `user.shell` and `user.terminal` become packages;
the system enables the program for each user's shell. Core persists the user
key directory, the flake checkout and the data directories for every user;
sops reads the host key from `/persist` only under impermanence;
`persist.system` no longer breaks machines without impermanence; scripts are
built with shellcheck.

**Verification.** Home packages and session variables of every example user
evaluate unchanged; the system lost only the standalone `home-manager` CLI
and an explicit `coreutils`; perseus built fully.

## PR 13: Fix `nix system build`, OBS `global.ini` and swapped MIME types

2026-11-12 · Commits `9ae615a`

**Why.** `nix system build` called `nix-store diff-closure`, which does not
exist; OBS wrote the user settings into `global.ini`; `modules.open` mapped
video to `audio/mp3` and audio to `video/mp4`.

**Changes.** `nix store diff-closures`, `settings.global`, and the MIME lists
swapped back.

**Verification.** The command was checked to exist; both machines evaluate.

## PR 12: Overlay llm-agents packages into nixpkgs

2026-11-12 · Commits `5df4079`

**Why.** The llm module reached into the llm-agents flake input directly.

**Changes.** The framework layer applies llm-agents' `shared-nixpkgs`
overlay, so `pkgs.llm-agents.<name>` exists on every machine.

**Verification.** `claude-desktop` is the same derivation through the overlay;
both machines unchanged.

## PR 11: Fold patches into overlays

2026-11-12 · Commits `550b26b`

**Why.** Overlays and patches lived in two directories with a hidden order
between them.

**Changes.** `overlays/<attr>/` holds `package.nix` and/or `*.patch`;
`mkPatchOverlay` merged into `mkOverlaysFrom`; a directory with neither fails.

**Verification.** Fixture tests for both and neither; breaking patch
application failed them; both machines unchanged.

## PR 10: Move tests to the repository root

2026-11-11 · Commits `607781b`

`lib/tests/` became `tests/`, with references updated.

## PR 9: Add CLAUDE.md

2026-11-11 · Commits `0de2d19`

Agent guidance on top of the README: repository map, verification commands,
hard rules (no switching, no secret edits), evaluation-order pitfalls, and how
to extend modules, overlays, machines and users.

## PR 8: Make framework overlays always-on policy

2026-11-11 · Commits `54ea4b5`

The repository's overlays and patches apply to every machine with no options;
machines layer their own on top and see the framework's packages as `prev`.
`package.nix` receives `prev` only when it declares it, which fixed
unreal-engine never evaluating. Both machines evaluated to the same
derivations.

## PR 7: Pick up machine overlays and patches by convention

2026-11-11 · Commits `40dfc04`, `1ca3625`

A machine's `overlays/<name>/package.nix` and `patches/<attr>/*.patch` apply
automatically for the system and every user, wired in `lib/overlays.nix`. A
fixture check covers the helpers; perseus demonstrates an overlay and a patch.

## PR 6: Move flake templates into the andromeda example

2026-11-11 · Commits `62ca4c4`

The development templates are personal; andromeda's flake exports them and the
root flake no longer does.

## PR 5: Add the perseus example

2026-11-11 · Commits `214b6c9`

Ported from `main`: impermanence, Wi-Fi from secrets and a seanime service,
exposed by the root flake next to andromeda.

## PR 4: Make examples standalone machine flakes

2026-11-11 · Commits `4e79f2f`

Each example has a `flake.nix` consuming the framework through a relative
path; the root flake exposes them by calling their outputs with itself.

## PR 3: Group machine files under `hardware/` and `system/`

2026-11-11 · Commits `664ceba`, `c75dea1`, `ce1f42a`

`mkMachine` requires `hardware/default.nix`, `hardware/disk.nix` and
`system/default.nix`, with `system/persist.nix` optional.

## PR 2: Rename features to modules, fold internals into `lib/`

2026-11-11 · Commits `c6298d2`

`features/` became `modules/` under `modules.<name>`; the builder, per-user
module, ISO and helpers moved into `lib/`. The evaluated system was
unchanged.

## PR 1: Turn the repository into a single-machine, multi-user framework

2026-11-11 · Commits `fdcc2f4`

`mkMachine` takes a machine directory and returns one `nixosConfiguration`
with embedded Home Manager. `meta.json` is replaced by typed `machine.*` and
`user.*` options; features with system and home halves, where a user enabling
one enables its system half. andromeda moved to `examples/`.
