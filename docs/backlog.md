# Backlog

Finished work and the small tasks that come next. Larger goals are in
[roadmap.md](roadmap.md), the reasoning behind current choices in
[design.md](design.md), and the test plan in [testing.md](testing.md).

Status as of 2026-11-12, branch `demo`.

## Needs your action

These cannot be done from the repository alone.

| Item | Why | What to do |
|------|-----|------------|
| andromeda lacks `password/tester` | sops-nix validates secret keys at build time, so andromeda only builds with `sops.validateSopsFiles = false` | `nixos-secrets host edit examples/andromeda` on andromeda and add a yescrypt hash |
| Host key location on machines installed by the old bootstrap | The old bootstrap always wrote the host key to `/persist/etc/ssh/...`, and sops used to try both paths. sops now reads `/etc/ssh/...` on machines without impermanence | Before switching such a machine, check `sudo ls /persist/etc/ssh /etc/ssh`; if the key that matches `.sops.yaml` is only under `/persist`, copy it to `/etc/ssh` |
| Personal data in git history | The old firefox module contained a Firefox Sync email, sync and telemetry IDs; it is gone from the tree but still in history, including `main` | Decide whether to rewrite history (`git filter-repo`) before the repository is promoted as a framework |
| Plaintext seanime password | `examples/perseus/overlays/seanime-server` passes `--password encryptlater` on the command line, readable in the store, with the server on all interfaces | Move it to a sops secret and an environment file, or bind to localhost |

## Done

### Framework foundation (2026-11-11)

| Commit | Change |
|--------|--------|
| `fdcc2f4` | Turned the repository into a single-machine, multi-user framework: `mkMachine` replaces `meta.json` |
| `c6298d2` | Renamed features to modules and folded framework internals into `lib/` |
| `664ceba`, `c75dea1`, `ce1f42a` | Grouped machine files into `hardware/` and `system/`, required files enforced by name |
| `4e79f2f` | Examples became standalone machine flakes, also exposed by the root flake |
| `214b6c9` | Added perseus: impermanence, Wi-Fi from secrets, a system service |
| `62ca4c4` | Moved the flake templates into the andromeda example |
| `40dfc04`, `1ca3625`, `54ea4b5` | Machine overlays and patches by convention, wired in `lib/overlays.nix`; framework overlays became always-on policy |
| `0de2d19` | Added CLAUDE.md for agents on top of the README |
| `607781b` | Moved the fixture tests to `tests/` |

### Framework MVP (2026-11-12)

| Commit | Change |
|--------|--------|
| `550b26b` | Patches folded into overlays: `overlays/<attr>/` holds `package.nix` and/or `*.patch` |
| `5df4079` | llm-agents overlay in the framework layer, as `pkgs.llm-agents.<name>` |
| `9ae615a` | Fixed `nix system build` (nonexistent `nix-store diff-closure`), OBS `global.ini`, swapped video/audio MIME types |
| `5578f53` | Core reduced to framework essentials; new `cli` and `theme` modules; time zone native; shell and terminal as packages; core persists the user key, checkout and data directories; `persist.system` no longer breaks machines without impermanence; scripts built with shellcheck |
| `91c20e7` | `nixos-secrets` replaces the just secrets module: works on any machine directory, `new` keeps the generated keys in an archive, `update` implemented |
| `6e58e1d` | Bootstrap and homestrap install any machine repository; host key written where sops reads it; homestrap re-runnable; ISO automation passes the repository and escapes its values |
| `d121f03` | Firefox module keeps chosen preferences only, no personal data |
| `267ffaa` | Personal settings (Claude plugins, Unreal rules, Arch container, input methods) moved into the example users |
| `a61f2d4` | git identity from secrets is opt-in; virtualization no longer forces the NVIDIA toolkit; hyprland starts fcitx5 only when configured and its default apps are overridable |
| `a497877` | Removed no-op framework overlays (openldap, bottles), moved unreal-engine to andromeda, dropped the unused caelestia input |
| `8af165d` | `nix system <action>` passes the machine flake for every action |

### Before the framework (main)

Default shell at user level, script paths shared as variables, user
directories instead of hardcoded persistence paths. User-level persistence
without a system switch became moot once Home Manager was embedded.

## Next: small tasks

Each of these fits in one commit.

### Install and secrets

| Task | Why |
|------|-----|
| `nixos-secrets adduser <host> <user>` that generates one user key into `<host>-<user>.tar.gz` | Adding a user to an existing machine needs manual `ssh-keygen` today (guide 6.4) |
| `nixos-secrets edit <file>` that decrypts with the host key and your key together | Editing another user's file with an admin key currently means calling `sops` by hand |
| A `hardware-config` helper on the ISO that prints `nixos-generate-config --no-filesystems --show-hardware-config` and the disk ids | The two facts every new machine needs from the target before installing |
| Confirm the target device in `just flash` before `dd` | `dd` to the wrong device destroys data |
| Prompt for the Wi-Fi password at boot instead of baking it into the ISO | The password ends up in the store and on the stick (design 21) |
| Make `nixos-secrets backup` refuse to run when no user key exists at all | It currently writes an archive with only the host key and a warning |

### Framework API

| Task | Why |
|------|-----|
| Assert that every `users/<name>` has a `home.nix`, with a clear message | Today it fails with a raw import error |
| Assert that `networking.hostName` is set | Without it the output is silently named `nixos` |
| Validate the shape of `persist.nix` (only `directories` and `files`) | Typos are silently ignored |
| Let `mkMachine` accept `{ inputs; modules; }` next to the path | Machines cannot use flakes of their own (design 6) |
| Discover machine-local `modules/<name>/` with `defineModule` | Machines cannot add modules in the framework's format (design 5) |
| Support assertions in home halves of modules | `defineModule` only forwards assertions for system halves |

### Modules

| Task | Why |
|------|-----|
| `open.sh`: replace the hardcoded editor list | Marked `todo` in the script |
| `modules.open`: cover more MIME types per category (`audio/mpeg`, `audio/flac`, `video/webm`, `image/svg+xml`, ...) | Each category handles one or two types |
| Check whether `hyprland`'s `modules.open.html = firefox` collides with the `firefox` module's package | Both install a Firefox |
| Check whether `llm` should persist `~/.claude.json` under impermanence without creating it empty | Claude stores its login there |
| Split `hyprland` keybindings and noctalia settings into overridable options or a profile | They are one person's taste (design 7) |

### Tests and CI

| Task | Why |
|------|-----|
| `just verify` running formatting, shellcheck of all scripts and `nix flake check` | One command to know the state before and after a change (testing.md, step 1) |
| Snapshots of the examples as a check, with `just snapshot update` | Turns this round's manual before/after diffs into a reviewable check (testing.md, step 2) |
| `defineModule` tests with `lib.debug.runTests` | The module format is untested (testing.md, step 3) |
| Fixture checks for core persistence (nesting filter) and peruser shell enabling | New logic from this round is verified by evaluation only |
| GitHub Actions running `just verify` on every push | Nothing runs the checks automatically |
| Throwaway test keys for the examples | Lets CI build and boot the examples (testing.md, step 4) |

### Docs

| Task | Why |
|------|-----|
| Generate the options reference in the guide from the option declarations | The tables in guide section 7 are maintained by hand |
| Document each module's system-wide effect when one user enables it | One user's choice changes the machine for everyone (design 4) |
