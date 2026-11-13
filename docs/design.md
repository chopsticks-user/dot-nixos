# Design decisions

Every decision the framework currently makes, why it was made, what it costs,
and a recommendation. This is the list to go through when deciding what to
keep, remove or improve. How the framework is used is in
[guide.md](guide.md).

## Summary

| # | Decision | Recommendation |
|---|----------|----------------|
| 1 | One machine per flake, built by `mkMachine ./.` | Keep |
| 2 | Directory conventions instead of options | Keep |
| 3 | Embedded Home Manager, a user described in one place | Keep |
| 4 | System halves enabled from what users enable | Keep |
| 5 | Custom module format (`defineModule`) | Keep, improve |
| 6 | Only the framework's inputs reach machine modules | Improve |
| 7 | Opinionated modules shipped inside the framework | Improve |
| 8 | Personal default home layout | Decide |
| 9 | Framework persists what it creates in home | Keep |
| 10 | Host SSH key as the sops identity | Keep |
| 11 | One host secrets file plus one per user | Keep |
| 12 | Scripts installed on every machine with baked paths | Keep |
| 13 | Installer: ISO plus bootstrap and homestrap | Improve |
| 14 | Keys fetched by an arbitrary command, sshd with passwords | Decide |
| 15 | `nix system` wrapper that shadows `nix` | Decide |
| 16 | NetworkManager and Wi-Fi from secrets in core | Keep |
| 17 | Latest kernel by default | Decide |
| 18 | Two overlay layers, framework layer always on | Keep |
| 19 | `llm-agents` overlay in the framework layer | Decide |
| 20 | Unfree packages allowed by name | Keep |
| 21 | Auto-bootstrap values baked into the ISO | Improve |
| 22 | `persist.nix` files are plain attribute sets | Keep |
| 23 | Examples double as CI and as the author's machines | Improve |
| 24 | Shell and terminal as packages | Keep |

## 1. One machine per flake

**What.** A machine is its own flake whose only input is dot-nixos.
`mkMachine ./.` returns exactly one `nixosConfigurations` entry.

**Why.** A machine repository stays small and self-contained, can be public
(secrets are encrypted), and updates as a unit with `nix flake update
dot-nixos`. It is also the shape a generator can produce mechanically.

**Cost.** Several machines mean several repositories, and shared settings
between them need a common flake of their own. Fleet tools (deploy-rs,
colmena) expect one flake with many hosts.

**Recommendation.** Keep. Multi-machine repositories can come later as a
thin layer that calls `mkMachine` per subdirectory, as the root flake already
does for the examples.

## 2. Directory conventions instead of options

**What.** `mkMachine` finds everything by path: `system/default.nix`,
`hardware/disk.nix`, `users/<name>/home.nix`, `overlays/<attr>/`, and
`system/persist.nix` switches impermanence on by existing.

**Why.** Nothing to wire. Adding a user is creating a directory. The layout
documents the machine.

**Cost.** Behaviour depends on which files exist, which is less discoverable
than options and cannot be set conditionally. Errors for a misnamed file are
whatever Nix says (only the required files get a clear message).

**Recommendation.** Keep. Add clear assertion messages for every convention
(issues 15, 16).

## 3. Embedded Home Manager, a user in one place

**What.** Home Manager runs as a NixOS module. `users/<name>/home.nix` holds
everything about a user, including account fields (`user.description`,
`user.groups`, `user.shell`) that the system reads back.

**Why.** One build and one generation for the system and all homes, so they
cannot drift; rollbacks cover both. Philosophy 2.

**Cost.** Changing a dotfile needs a system rebuild with root. One user's
broken `home.nix` blocks the machine. A user's config cannot be reused on a
non-NixOS machine. Reading Home Manager values from the system is the source
of the evaluation-order traps listed in CLAUDE.md.

**Recommendation.** Keep. If a non-NixOS target appears, add a
`homeConfigurations` output next to the module rather than switching to
standalone Home Manager.

## 4. System halves enabled from what users enable

**What.** A module's system half turns on when any user enables its home
half; `modules.gaming` in one `home.nix` installs Steam for the machine.

**Why.** The user is the unit of intent; the machine follows.

**Cost.** One user's choice affects everyone (system packages, open firewall
ports). Disabling a system half while a user wants it requires
`lib.mkForce false`.

**Recommendation.** Keep. Document per module what its system half changes
for the whole machine (the guide's module table is a start).

## 5. Custom module format

**What.** Modules return `{ options; configs; imports; assertions;
allowUnfree; persist; }`, and `defineModule` turns that into a guarded module
under `modules.<name>`, adding `enable`, the unfree allowlist and persistence.

**Why.** Every module gets the same enable guard, namespace, unfree handling
and persistence wiring, without repeating `mkIf cfg.enable` boilerplate. It
keeps `allowUnfree` outside the guard, which avoids a recursion through Home
Manager.

**Cost.** It is a dialect: contributors must learn it, and assertions only
work in system halves. Machines cannot add modules in this format, because
discovery only reads the framework's `modules/`.

**Recommendation.** Keep the format. Let machines add `modules/<name>/` by the
same convention (issue 18), so a consumer's own features follow the same rules.

## 6. Only the framework's inputs reach machine modules

**What.** `inputs` in every module is the framework's inputs. The machine
flake's own inputs are not passed, and `mkMachine` takes nothing but a path.

**Why.** It keeps the example flakes callable by the root flake with only
`dot-nixos`, and keeps the API to one argument.

**Cost.** A consumer who needs another flake (a hardware module, a custom
package set, a private module repository) has no supported way in.

**Recommendation.** Improve: let `mkMachine` take an optional attribute set
(for example `{ inputs; modules; }`) merged into `specialArgs` and the module
list, while keeping `mkMachine ./.` working.

## 7. Opinionated modules inside the framework

**What.** Besides `core`, the framework ships 19 feature modules, several of
them one person's setup: Hyprland with a 740-line noctalia config and
keybindings, an nvf Neovim configuration, VS Code and Zed settings, a pink
cursor, Fira fonts.

**Why.** Philosophy 3: opinionated, with sensible defaults. A new machine is
useful immediately.

**Cost.** The framework's quality bar now includes keeping these configs
working across nixpkgs updates. Personal taste is hard to override field by
field. The line between framework and preferences is blurry, which is what
the cleanup in this round had to untangle.

**Recommendation.** Improve: separate the framework (lib, core, install,
secrets, overlays) from a catalog of profiles (desktop, editor, gaming,
server), so a generator can offer profiles and the core stays small. The
roadmap's catalog milestone covers this.

## 8. Personal default home layout

**What.** `machine.directories.home` defaults to a particular layout:
`downloads`, `projects`, `media/images`, `media/audio`, `boxes`, and the
desktop, templates and public directories hidden under
`.local/share/.xdg-ignore`.

**Why.** It is the author's preferred layout, and it is consistent across
modules (screenshots, recordings, containers).

**Cost.** It differs from the XDG defaults (`Downloads`, `Pictures`) that
most people and applications expect.

**Recommendation.** Decide: keep it as the framework's opinion, or default to
the XDG names and move this layout into an example. Either way it is one
option to override.

## 9. Framework persists what it creates in home

**What.** Under impermanence, core persists for every user the directory of
the user key (mode 0700), the flake checkout and the data directories. Modules
add their own paths for users who enable them.

**Why.** Homestrap places the key and the checkout; losing them on reboot
breaks secrets and rebuilds. Users no longer repeat the same list.

**Cost.** Users cannot opt out of persisting the data directories, and must
not list them again (impermanence rejects duplicates).

**Recommendation.** Keep.

## 10. Host SSH key as the sops identity

**What.** sops-nix converts the host's ed25519 SSH key to an age identity.
With impermanence it reads the key under `/persist`, because it decrypts
before bind mounts exist.

**Why.** One key per machine, which the installer places; no separate age key
to manage.

**Cost.** The host key's lifetime is the secrets' lifetime: rotating the SSH
host key means re-encrypting. A machine installed by the old bootstrap, which
always wrote the key under `/persist`, decrypts nothing after this round's
change unless its key is also at `/etc/ssh` (issue 6).

**Recommendation.** Keep.

## 11. Secrets layout

**What.** `secrets.yaml` (host) holds the root and user password hashes and
Wi-Fi credentials. `users/<name>/secrets.yaml` holds a user's secrets,
decrypted by their own key; the git identity can come from it.

**Why.** A user's secrets are readable only by that user and whoever they
add, not by the host.

**Cost.** Password hashes live in the host file, so a user cannot change
their own password declaratively without the host key or an admin key.

**Recommendation.** Keep. Recommend an admin key in every rule (the guide
does).

## 12. Scripts installed with baked paths

**What.** `nixos-homestrap`, `nixos-secrets` and `nix-system` are built per
machine with `writeShellApplication`; the flake checkout, key paths and user
list are baked in at build time.

**Why.** The scripts need no evaluation at runtime, work offline, and
shellcheck runs at build time.

**Cost.** Commands for a different machine (creating a new machine's files)
take a directory argument instead of knowing it.

**Recommendation.** Keep for on-machine commands. Commands that create or
manage other machines belong in a separate generator CLI (roadmap).

## 13. Installer: ISO, bootstrap, homestrap

**What.** A custom ISO with `nixos-bootstrap` (partition with disko, place
the host key, install from the repository) and, after reboot,
`nixos-homestrap` per user (clone, place the user key).

**Why.** Installs straight from the machine repository, with secrets working
on first boot.

**Cost.** Two reboots, manual steps per user, and the hardware configuration
has to be generated on the target and committed before installing. The
scripts are tested with faked commands, but nothing installs onto a disk in a
test yet.

**Recommendation.** Improve: test the flow in a VM (testing.md), and evaluate
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) (install
over SSH with disko, extra files such as keys) and
[nixos-facter](https://github.com/nix-community/nixos-facter) (hardware
report) as the generator's install path.

## 14. Keys fetched by an arbitrary command

**What.** Bootstrap and homestrap take a command that prints the private key,
typically SSH to the dev machine. The `ssh` module enables password login so
the installer can reach the dev machine.

**Why.** No assumption about where keys are kept.

**Cost.** Password login on every machine with the `ssh` module, for a need
that exists only during installation.

**Recommendation.** Decide: keep, or turn password login off by default and
have the generator push keys to the target instead (nixos-anywhere's
`--extra-files` does this).

## 15. `nix system` wrapper

**What.** Core installs a `nix` script in front of the real one, so
`nix system build|switch|info` runs `nix-system`; everything else passes
through.

**Why.** A memorable command that diffs before switching.

**Cost.** Shadowing `nix` is surprising, and its position in `PATH` decides
which `nix` runs. `nh` (module) already offers diffs and confirmation.

**Recommendation.** Decide: keep, or drop the wrapper and keep `nix-system`
(or rely on `nh`).

## 16. NetworkManager and Wi-Fi in core

**What.** Core enables NetworkManager with an ethernet profile and Wi-Fi
profiles whose credentials come from secrets.

**Why.** Declarative Wi-Fi without plaintext passwords.

**Cost.** Servers that want systemd-networkd get NetworkManager anyway.

**Recommendation.** Keep, possibly as a `network` module enabled by default.

## 17. Latest kernel by default

**What.** `boot.kernelPackages` defaults to `linuxPackages_latest` (a
default, overridable).

**Why.** Newest hardware support.

**Cost.** Out-of-tree modules (NVIDIA, ZFS) break first on the latest kernel.

**Recommendation.** Decide: keep, or follow the NixOS default and let
hardware profiles opt in.

## 18. Two overlay layers

**What.** The framework's `overlays/` applies to every machine, then the
machine's. Same layout in both: `<attr>/package.nix` and `<attr>/*.patch`.

**Why.** One concept for every change to nixpkgs; machines layer instead of
configure.

**Cost.** Nothing in the framework layer can be switched off by a machine.

**Recommendation.** Keep. The framework layer is empty today and should stay
reserved for fixes every machine needs.

## 19. `llm-agents` in the framework layer

**What.** The framework applies the llm-agents overlay, adding
`pkgs.llm-agents.<name>` to every machine.

**Why.** One place for AI agent packages, built against the system nixpkgs.

**Cost.** A framework input and overlay that most machines may not use; it
is evaluated lazily, so the runtime cost is small.

**Recommendation.** Decide: keep, or move it behind the `llm` module (which
would then need the overlay applied conditionally, without making `pkgs`
depend on Home Manager).

## 20. Unfree packages by name

**What.** `allowUnfree = [ ... ]` in modules and
`nixpkgs.config.allowUnfreePackages` elsewhere.

**Why.** Explicit, reviewable, and kept outside enable guards to avoid
recursion.

**Cost.** Allowlisted names apply even when the module is off (harmless).

**Recommendation.** Keep.

## 21. Auto-bootstrap values baked into the ISO

**What.** `just flash` with automation reads Wi-Fi credentials, the
repository and key commands from the environment and bakes them into the ISO
(impure build).

**Why.** An unattended install.

**Cost.** The Wi-Fi password is in the Nix store of the dev machine and on
the stick.

**Recommendation.** Improve: prompt for the Wi-Fi password at boot, or let
the generator write a small config file onto the stick instead.

## 22. `persist.nix` as plain attribute sets

**What.** `system/persist.nix` and `users/<name>/persist.nix` are imported as
data, not modules.

**Why.** Their presence is checked before evaluation (it decides whether
impermanence is imported), and data is easy to generate.

**Cost.** They cannot use `config` or `pkgs`.

**Recommendation.** Keep.

## 23. Examples as CI and the author's machines

**What.** The examples are complete machines, built by the root flake's
checks; andromeda and perseus are also the author's real machines.

**Why.** Real configurations exercise real paths.

**Cost.** Personal choices leak into what reads as reference material, and
the examples cannot be fully built in CI because their secrets need keys
(andromeda also lacks `password/tester`).

**Recommendation.** Improve: keep personal machines in a separate repository
built on the framework, and give the examples throwaway keys committed for
tests (testing.md), so CI builds and boots them.

## 24. Shell and terminal as packages

**What.** `user.shell` and `user.terminal` are packages; the system enables
`programs.<shell>` for zsh, fish or xonsh.

**Why.** Typed, typo-proof, and works for shells whose attribute and binary
names differ (`bashInteractive`).

**Cost.** None found.

**Recommendation.** Keep.
