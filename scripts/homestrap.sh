#!/usr/bin/env bash
set -euo pipefail

no_reboot=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-reboot) no_reboot=true; shift ;;
    *) break ;;
  esac
done

key_content=$(eval "$1")

config_path="${NIXOS_FLAKE_DIR:-$HOME/.config/nixos}"
mkdir -p "$(dirname "$config_path")"
git clone https://github.com/chopsticks-user/dot-nixos "$config_path"
cd "$config_path"

home_identity="$HOME/${NIXOS_HOME_IDENTITY:-.ssh/id_ed25519}"
if [ ! -f "$home_identity" ]; then
  mkdir -p "$(dirname "$home_identity")"
  echo "$key_content" | tee "$home_identity" > /dev/null
  chmod 600 "$home_identity"
  ssh-keygen -y -f "$home_identity" > "$home_identity.pub"
  chmod 644 "$home_identity.pub"
fi

# home-manager is part of the system build, so placing the key is all the user side needs
nix-collect-garbage -d
sudo nix-collect-garbage -d
sudo nix store optimise
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

if [[ "$no_reboot" == false ]]; then
  read -rp "Reboot now? (Y/n): " reboot_now
  if [[ "${reboot_now,,}" != "n" ]]; then
    reboot
  fi
fi
