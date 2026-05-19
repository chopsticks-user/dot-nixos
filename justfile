mod secrets "scripts/secrets.just"

[private]
default:
  @just --list --list-submodules

help:
  @just

flash device="/dev/sda" arch=`nix eval --impure --raw --expr 'builtins.currentSystem'`:
  ./scripts/flash.sh {{device}} {{arch}}

bootstrap host:
  ./scripts/bootstrap.sh {{host}}

install:
  ./scripts/install.sh