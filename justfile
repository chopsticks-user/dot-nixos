mod secrets "scripts/secrets.just"

[private]
default:
  @just --list --list-submodules

help:
  @just

flash device="/dev/sda" system=`nix eval --impure --raw --expr 'builtins.currentSystem'`:
  #!/usr/bin/env bash
  set -euo pipefail

  nix build .#nixosConfigurations.iso-"{{system}}".config.system.build.isoImage
  sudo dd if="$(ls result/iso/*.iso)" of="{{device}}" bs=4M status=progress oflag=sync

test args:
  @echo "{{args}}"
