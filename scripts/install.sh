#!/usr/bin/env bash

set -euo pipefail

key_content=$(eval "$1")

config_path_rel=$(jq -r ".directories.nixos" <(curl -s https://raw.githubusercontent.com/chopsticks-user/dot-nixos/main/meta.json))
if [ -z "$config_path_rel" ] || [ "$config_path_rel" = "null" ]; then
  echo "Could not read directories.nixos from meta.json" >&2
  exit 1
fi
config_path=${config_path_rel/#\$HOME/$HOME}
mkdir -p "$(dirname "$config_path")"
git clone https://github.com/chopsticks-user/dot-nixos "$config_path"
cd "$config_path"

home_identity="$HOME/$(jq -r ".directories.home.identity" meta.json)"
if [ ! -f "$home_identity" ]; then
  mkdir -p "$(dirname "$home_identity")"
  echo "$key_content" | tee "$home_identity" > /dev/null
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

read -rp "Reboot now? (Y/n): " reboot_now
if [[ "${reboot_now,,}" != "n" ]]; then
  reboot
fi
