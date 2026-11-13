# Issues

The issue tracker: problems and planned work, open and closed. Finished work
is logged as pull requests in [backlog.md](backlog.md); larger goals are in
[roadmap.md](roadmap.md).

Labels: `bug`, `security`, `enhancement`, `tests`, `docs`, `needs-owner`
(cannot be done from the repository alone).

## Index

| # | Title | Labels | Status |
|---|-------|--------|--------|
| 1 | Impermanence guard fails when no `environment` option exists | bug | Closed by PR 25 |
| 2 | Overriding one well-known directory drops all the others | bug | Closed by PR 26 |
| 3 | Missing `secrets.yaml` or `home.nix` is only noticed late | bug | Closed by PR 27 |
| 4 | `just flash` fails for key commands containing `$` or backticks | bug | Closed by PR 28 |
| 5 | andromeda lacks `password/tester` | needs-owner | Open |
| 6 | Host key may be only under `/persist` on machines installed by the old bootstrap | bug, needs-owner | Open |
| 7 | Personal data in git history | security, needs-owner | Open |
| 8 | Plaintext seanime password in the perseus example | security | Open |
| 9 | No command to add a user key to an existing machine | enhancement | Open |
| 10 | No command to edit a secrets file with several keys at once | enhancement | Open |
| 11 | No helper on the installer to collect hardware facts | enhancement | Open |
| 12 | `just flash` writes to the device without confirmation | security | Open |
| 13 | Wi-Fi password baked into the ISO | security | Open |
| 14 | `nixos-secrets backup` writes an archive without any user key | bug | Open |
| 15 | Unset host name silently names the output `nixos` | enhancement | Open |
| 16 | `persist.nix` files are not validated | enhancement | Open |
| 17 | Machines cannot use flakes of their own | enhancement | Open |
| 18 | Machines cannot add modules in the framework's format | enhancement | Open |
| 19 | Home halves of modules cannot declare assertions | enhancement | Open |
| 20 | `open.sh` hardcodes a list of editors | enhancement | Open |
| 21 | `modules.open` covers one or two MIME types per category | enhancement | Open |
| 22 | `hyprland` and `firefox` may both install a Firefox | bug | Open |
| 23 | `llm` does not persist `~/.claude.json` | bug | Open |
| 24 | Hyprland keybindings and noctalia settings cannot be adjusted piecemeal | enhancement | Open |
| 25 | No snapshots of the examples | tests | Open |
| 26 | No test that every module evaluates on its own | tests | Open |
| 27 | No continuous integration | tests | Open |
| 28 | No VM tests with throwaway keys | tests | Open |
| 29 | No test of the install flow on a disk | tests | Open |
| 30 | Error messages of `mkMachine` are not tested | tests | Open |
| 31 | Option reference in the guide is maintained by hand | docs | Open |
| 32 | Undocumented machine-wide effects of user modules | docs | Open |

## Closed

These were found by the test suite added in PRs 24 to 29 and fixed in the
same round.

### #1 Impermanence guard fails when no `environment` option exists

`bug` · Opened 2026-11-12 · Closed by PR 25 (`d180cee`)

`defineModule`, `peruser.nix` and the core module detected impermanence
with `options.environment ? persistence`. When a module set has no
`environment` option at all, that expression is an error ("attribute
'environment' missing") instead of `false`. NixOS always declares
`environment`, so no machine was affected, but the guard broke as soon as
`defineModule` was evaluated on its own in the unit tests.

Fixed by using `options ? environment.persistence`, which is `false` in both
cases, everywhere, and in the CLAUDE.md pitfall.

### #2 Overriding one well-known directory drops all the others

`bug` · Opened 2026-11-12 · Closed by PR 26 (`315b5c9`)

`machine.directories.home` and `user.directories` were attribute set options
whose whole value was the default. Setting a single key, for example
`machine.directories.home.pictures = "pictures";`, replaced the default, so
`documents`, `identity` and every other directory disappeared. The guide
already told consumers to override keys this way.

Found while writing the `impermanent` fixture, which moves `pictures` out of
`media`. Fixed by defining each key as its own `mkDefault`, so an override
changes only that key.

### #3 Missing `secrets.yaml` or `home.nix` is only noticed late

`bug` · Opened 2026-11-12 · Closed by PR 27 (`d047444`)

`mkMachine` checked required files only where they were used. `secrets.yaml`
was read once sops evaluated and `users/<name>/home.nix` once Home Manager
evaluated that user, so a machine missing either evaluated its name fine and
failed much later, with a raw import error for `home.nix`.

Found by the error cases in the `machines` check. Fixed by checking every
required file, and each user's `home.nix`, when `mkMachine` is called, with
the `mkMachine: <path> is required` message.

### #4 `just flash` fails for key commands containing `$` or backticks

`bug` · Opened 2026-11-12 · Closed by PR 28 (`0180544`)

The ISO's automatic bootstrap bakes the key commands into a script built with
`writeShellApplication`, whose shellcheck run rejects single-quoted text that
looks like an expansion (SC2016). A key command such as
`ssh me@dev 'cat $HOME/keys/host.key'` therefore failed the ISO build, even
though the value is meant to be literal.

Found by `script-iso-bootstrap`, which builds the script with hostile values.
Fixed by excluding SC2016 for that script.

## Open

### #5 andromeda lacks `password/tester`

`needs-owner` · Opened 2026-11-11

sops-nix validates secret keys at build time, and andromeda's `secrets.yaml`
has no `password/tester`, so andromeda only builds with
`sops.validateSopsFiles = false`. On andromeda, run
`nixos-secrets host edit examples/andromeda` and add a yescrypt hash
(`nix run nixpkgs#mkpasswd -- -m yescrypt`).

### #6 Host key may be only under `/persist` on machines installed by the old bootstrap

`bug`, `needs-owner` · Opened 2026-11-12

The old bootstrap always wrote the host key to `/persist/etc/ssh/...`, and
sops used to try both that path and `/etc/ssh/...`. Since PR 14, sops reads
only `/etc/ssh/...` on machines without impermanence. A machine installed
by the old bootstrap whose key exists only under `/persist` would stop
decrypting its secrets after switching. Before switching such a machine, run
`sudo ls /persist/etc/ssh /etc/ssh`; if the key matching `.sops.yaml` is only
under `/persist`, copy it to `/etc/ssh`.

### #7 Personal data in git history

`security`, `needs-owner` · Opened 2026-11-12

The old firefox module contained a Firefox Sync account email and sync and
telemetry IDs. PR 17 removed them from the tree, but they remain in history,
including `main`. Decide whether to rewrite history (`git filter-repo`)
before the repository is promoted as a framework.

### #8 Plaintext seanime password in the perseus example

`security` · Opened 2026-11-11

`examples/perseus/overlays/seanime-server` passes `--password encryptlater`
on the command line, so it is in the Nix store and the process list, and the
server listens on all interfaces. Move the password to a sops secret and an
environment file, or bind to localhost.

### #9 No command to add a user key to an existing machine

`enhancement` · Opened 2026-11-12

`nixos-secrets new` generates a host key and user keys together. Adding a
user later needs `ssh-keygen` by hand (guide 6.4). Proposal:
`nixos-secrets adduser <host> <user>`, writing `<host>-<user>.tar.gz` and
printing the age public key.

### #10 No command to edit a secrets file with several keys at once

`enhancement` · Opened 2026-11-12

`nixos-secrets host` and `user` each decrypt with one key. Editing another
user's file with an admin key means calling `sops` by hand. Proposal:
`nixos-secrets edit <file>` that offers the host key and your key together.

### #11 No helper on the installer to collect hardware facts

`enhancement` · Opened 2026-11-12

Every new machine needs `nixos-generate-config --no-filesystems
--show-hardware-config` and the disk ids from the target before installing.
Proposal: a `hardware-config` command on the ISO that prints both. The
roadmap's hardware detection milestone may replace it with nixos-facter.

### #12 `just flash` writes to the device without confirmation

`security` · Opened 2026-11-12

`just flash` runs `dd` to the given device directly. A wrong device argument
destroys data. Proposal: show the device's model and size and ask before
writing.

### #13 Wi-Fi password baked into the ISO

`security` · Opened 2026-11-12

With automated bootstrapping, the Wi-Fi password is read at build time and
ends up in the dev machine's store and on the stick (design 21). Proposal:
prompt for it at boot instead.

### #14 `nixos-secrets backup` writes an archive without any user key

`bug` · Opened 2026-11-12

When no user has a key, `backup` warns per user and still writes an archive
with only the host key. Proposal: refuse, or say clearly that the archive is
host-only.

### #15 Unset host name silently names the output `nixos`

`enhancement` · Opened 2026-11-12

`networking.hostName` defaults to `nixos`, so a machine that forgets to set it
produces `nixosConfigurations.nixos` without complaint. Proposal: make
`mkMachine` require it to be set explicitly.

### #16 `persist.nix` files are not validated

`enhancement` · Opened 2026-11-12

`system/persist.nix` and `users/<name>/persist.nix` are imported as data. A
typo such as `directorys` is silently ignored. Proposal: reject attributes
other than `directories` and `files`.

### #17 Machines cannot use flakes of their own

`enhancement` · Opened 2026-11-12

Only the framework's inputs reach machine modules, and `mkMachine` takes
only a path (design 6). Proposal: accept an optional `{ inputs; modules; }`
next to the path, merged into `specialArgs` and the module list.

### #18 Machines cannot add modules in the framework's format

`enhancement` · Opened 2026-11-12

Module discovery only reads the framework's `modules/` (design 5).
Proposal: discover a machine's own `modules/<name>/` with `defineModule` too.

### #19 Home halves of modules cannot declare assertions

`enhancement` · Opened 2026-11-12

`defineModule` forwards `assertions` only for system halves; in home halves
they are ignored without warning (covered by a test in `modules`). Proposal:
forward them to Home Manager's `assertions`.

### #20 `open.sh` hardcodes a list of editors

`enhancement` · Opened 2026-11-12

`open -c` treats commands matching `vi`, `vim`, `nvim`, `emacs` or `nano` as
terminal editors (marked `todo` in the script). Proposal: decide by whether
the command needs a terminal, or make the list configurable.

### #21 `modules.open` covers one or two MIME types per category

`enhancement` · Opened 2026-11-12

`modules/open/mime.nix` maps, for example, audio to `audio/mp3` only.
Proposal: cover common types per category (`audio/mpeg`, `audio/flac`,
`video/webm`, `image/svg+xml`, ...).

### #22 `hyprland` and `firefox` may both install a Firefox

`bug` · Opened 2026-11-12

`hyprland` sets `modules.open.html = pkgs.firefox`, which installs plain
Firefox, while the `firefox` module installs Home Manager's wrapped one.
Check whether both land in the profile, and point `open` at the module's
package when it is enabled.

### #23 `llm` does not persist `~/.claude.json`

`bug` · Opened 2026-11-12

Claude Code keeps its login in `~/.claude.json`, which `llm` does not persist
under impermanence, so users would log in after every boot. Persisting it as a
file may create an empty file on first boot, which is not valid JSON;
investigate before adding it.

### #24 Hyprland keybindings and noctalia settings cannot be adjusted piecemeal

`enhancement` · Opened 2026-11-12

The keybindings and the 740-line noctalia configuration are one person's
taste (design 7). Proposal: expose them as options or move them into a
desktop profile.

### #25 No snapshots of the examples

`tests` · Opened 2026-11-12

Intended changes to the examples can only be reviewed by diffing evaluated
values by hand. Plan in [testing.md](testing.md#snapshots-of-the-examples).

### #26 No test that every module evaluates on its own

`tests` · Opened 2026-11-12

A module that depends on another without enabling it goes unnoticed while
the examples enable both. Plan in [testing.md](testing.md#module-matrix).

### #27 No continuous integration

`tests` · Opened 2026-11-12

Nothing runs `just verify` automatically. Proposal: GitHub Actions on every
push, with a binary cache.

### #28 No VM tests with throwaway keys

`tests` · Opened 2026-11-12

Nothing boots a machine, decrypts its secrets or logs a user in. Plan in
[testing.md](testing.md#vm-tests).

### #29 No test of the install flow on a disk

`tests` · Opened 2026-11-12

`script-bootstrap` runs the script with disko and `nixos-install` faked.
Plan in [testing.md](testing.md#install-test).

### #30 Error messages of `mkMachine` are not tested

`tests` · Opened 2026-11-12

The error cases in `machines` check that evaluation fails, not which message
it fails with, because `builtins.tryEval` does not return it. Proposal: check
messages in a derivation that runs `nix eval` on the fixtures, or accept the
gap.

### #31 Option reference in the guide is maintained by hand

`docs` · Opened 2026-11-12

The tables in guide section 7 can drift from the option declarations.
Proposal: generate them from the options.

### #32 Undocumented machine-wide effects of user modules

`docs` · Opened 2026-11-12

When one user enables a module, its system half changes the machine for
everyone (design 4). Proposal: document per module what its system half
changes.
