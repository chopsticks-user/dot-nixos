mod secrets "scripts/secrets.just"

[private]
default:
  @just --list --list-submodules

help:
  @just

flash device="/dev/sda" arch=`nix eval --impure --raw --expr 'builtins.currentSystem'`:
  @sh ./scripts/flash.sh {{device}} {{arch}}

test args:
  @echo "{{args}}"
