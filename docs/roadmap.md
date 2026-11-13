# Roadmap

The goal is to turn dot-nixos from a framework you copy an example from into a
NixOS machine generator: describe a machine in a few answers or a short spec,
and get a complete, installable, encrypted machine repository, installed on
the target and kept up to date.

Small, concrete tasks live in [backlog.md](backlog.md). The decisions each
milestone revisits are numbered as in [design.md](design.md).

## Where it stands

Milestone 0 is done. The framework builds one machine with any number of users
from a directory (`mkMachine`), with embedded Home Manager, sops secrets,
optional impermanence, overlays and patches by convention, opt-in feature
modules, an installer that installs any machine repository, and
`nixos-secrets` for keys and secrets. Both examples build. What a generator
would produce is exactly what the examples are by hand.

## Milestones

### 1. A trustworthy base

Before generating machines, every generated machine has to be known to work.

- Automated tests at every layer described in [testing.md](testing.md):
  library fixtures, evaluation assertions, script tests, NixOS VM tests that
  boot a machine, decrypt its secrets and log users in, and a VM test of the
  full install flow.
- CI running them on every push.
- Clear errors for every convention (missing `home.nix`, unset host name,
  malformed `persist.nix`).
- `mkMachine` accepting extra inputs and modules, and machine-local
  `modules/<name>/` (design 5, 6), so generated machines can be extended
  without forking the framework.

Done when: a fresh machine from an example installs in a VM in CI, boots,
decrypts its secrets and logs every user in.

### 2. The machine spec

A generator needs an input format. Define a small spec that captures what
differs between machines and nothing else:

```nix
{
  hostName = "mymachine";
  timeZone = "Europe/Berlin";
  disk = { device = "/dev/disk/by-id/nvme-..."; layout = "impermanent-btrfs"; swap = "16G"; };
  hardware = [ "common-cpu-intel" "common-gpu-nvidia-nonprime" ];
  modules = [ "grub" "nh" "cli" ];
  users.alice = { description = "Alice"; profile = "desktop"; };
}
```

- Disk layouts as named templates (plain ext4, impermanent btrfs, encrypted
  variants) instead of hand-written disko files.
- Profiles that bundle modules (desktop, development, gaming, server),
  replacing hand-picked module lists (design 7).
- The spec is validated by the module system: an option tree, so errors point
  at the field.

Done when: both examples can be expressed as specs that generate the same
`drvPath` as today's hand-written files.

### 3. The generator CLI

`nix run github:chopsticks-user/dot-nixos#new` (name to be decided) that:

1. asks for the spec's fields, or reads a spec file;
2. writes the machine repository: `flake.nix`, `system/`, `hardware/`,
   `users/`, `.sops.yaml`;
3. generates the host and user keys into an archive (today's
   `nixos-secrets new`), asks for passwords and writes encrypted
   `secrets.yaml` files with their hashes;
4. initialises git and checks the result with `nix flake check`.

The commands that manage other machines move from the on-machine
`nixos-secrets` into this CLI (design 12); on-machine commands keep managing
the machine itself.

Done when: `new` plus `git push` produces a repository that installs without
editing a file.

### 4. Hardware detection

Generated machines need the target's hardware facts before install.

- Evaluate [nixos-facter](https://github.com/nix-community/nixos-facter): one
  report from the target drives `hardware/` (CPU, GPU, firmware, kernel
  modules) and offers the disk ids for the disk template.
- Map reports to nixos-hardware profiles and GPU settings (the NVIDIA setup in
  both examples is the first case).
- The installer prints or uploads the report, replacing the manual
  `nixos-generate-config` step.

Done when: a machine is generated from a facter report without opening
`hardware/`.

### 5. Install over the network

- Evaluate [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
  as the install path: it runs disko and installs over SSH from the dev
  machine, and can push the host key as an extra file. That removes the
  custom ISO's key commands, the password SSH login it needs (design 14), and
  the Wi-Fi password baked into the ISO (design 21).
- Keep the ISO for machines without network access to the dev machine,
  possibly as a thin wrapper around the same steps.
- User keys pushed the same way, so homestrap becomes only "clone the
  repository" or disappears.

Done when: `generate`, then one install command from the dev machine, gives a
booted machine with working secrets for every user.

### 6. Living with generated machines

- Regenerate from the spec without clobbering hand edits: generated files are
  marked, hand-written ones are left alone, and the generator reports drift.
- Framework updates that change the spec format come with a migration.
- Release tags and a changelog, so machines can pin a framework version and
  upgrade deliberately.

### 7. More than one machine

- An optional multi-machine repository (one flake, several machines), built
  by calling `mkMachine` per directory, with shared modules between them
  (design 1).
- Deployment to many machines (deploy-rs or colmena) on top of it.

## Out of scope for now

Non-NixOS targets (standalone Home Manager, nix-darwin) and graphical
configuration tools. Both can be reconsidered once the spec exists.
