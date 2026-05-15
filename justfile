mod secrets "scripts/secrets.just"

[private]
default:
  @just --list --list-submodules

help:
  @just