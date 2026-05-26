#!/usr/bin/env bash
set -euo pipefail

flake_dir="$(jq -r ".directories.nixos" meta.json | sed "s|\$HOME|$HOME|")"

command_build() {
  result=$(nixos-rebuild build --flake "$flake_dir#$(hostname)" "$@")
  nvd diff /run/current-system "$result"
  nix-store diff-closure "$result"
}

command_switch() {
  command_build
  read -rp "Apply? [y/N] " confirm
  [[ "${confirm,,}" == "y" ]] || exit 0
  sudo nixos-rebuild switch --flake "$flake_dir#$(hostname)" "$@"
}

command_info() {
  nixos-rebuild list-generations
}

case "${1:-}" in
  build) shift; command_build "$@" ;;
  switch) shift; command_switch "$@" ;;
  info) shift; command_info "$@" ;;
  *) exec nixos-rebuild "$@" ;;
esac