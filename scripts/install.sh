#!/usr/bin/env bash

set -euo pipefail

key_content=$(eval "$1")

tmp_clone=$(mktemp -d)
trap 'rm -rf "$tmp_clone"' EXIT
git clone https://github.com/chopsticks-user/dot-nixos "$tmp_clone"
config_path_rel=$(jq -r ".directories.nixos" "$tmp_clone/meta.json")
if [ -z "$config_path_rel" ] || [ "$config_path_rel" = "null" ]; then
  echo "Could not read directories.nixos from meta.json" >&2
  exit 1
fi
config_path=${config_path_rel/#\$HOME/$HOME}
if [ -e "$config_path" ]; then
  echo "$config_path already exists. Aborting." >&2
  exit 1
fi
mkdir -p "$(dirname "$config_path")"
mv "$tmp_clone" "$config_path"
trap - EXIT
cd "$config_path"

home_identity="$HOME/$(jq -r ".directories.home.identity" meta.json)"
if [ ! -f "$home_identity" ]; then
  mkdir -p "$(dirname "$home_identity")"
  echo "$key_content" | tee "$home_identity"
  chmod 600 "$home_identity"
  ssh-keygen -y -f "$home_identity" > "$home_identity.pub"
  chmod 644 "$home_identity.pub"
fi

username=$(whoami)
arch=$(nix eval --impure --raw --expr 'builtins.currentSystem')
home-manager switch --flake ".#$username@$arch"
nix-collect-garbage -d
sudo nix-collect-garbage -d
sudo nix store optimise
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
reboot
