#!/usr/bin/env bash

set -euo pipefail

host=$1
key_content=$(eval "$2")

tmp_clone=$(mktemp -d)
trap 'rm -rf "$tmp_clone"' EXIT
git clone https://github.com/chopsticks-user/dot-nixos "$tmp_clone"
config_path_rel=$(jq -r ".directories.nixos" "$tmp_clone/meta.json")
config_path=${config_path_rel/#\$HOME/$HOME}
if [ -z "$config_path_rel" ] || [ "$config_path_rel" = "null" ]; then
  echo "Could not read directories.nixos from meta.json" >&2
  exit 1
fi
rm -rf "$config_path"
mkdir -p "$(dirname "$config_path")"
mv "$tmp_clone" "$config_path"
trap - EXIT
cd "$config_path" || exit

if ! jq -e ".hosts.\"$host\"" meta.json > /dev/null; then
  echo "Error: host '$host' not found in meta.json" >&2
  exit 1
fi

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- --flake \
  ".#$host" --mode destroy,format,mount

system_identity=$(jq -r ".directories.system.identity" meta.json)
mnt_system_identity="/mnt$system_identity"
sudo mkdir -p "$(dirname "$mnt_system_identity")"
echo "$key_content" | sudo tee "$mnt_system_identity" > /dev/null
sudo chmod 600 "$mnt_system_identity"
sudo chown root:root "$mnt_system_identity"
sudo ssh-keygen -y -f "$mnt_system_identity" \
  | sudo tee "$mnt_system_identity.pub" > /dev/null
sudo chmod 644 "$mnt_system_identity.pub"

sudo nixos-generate-config --no-filesystems --root /mnt
sudo nixos-install --flake ".#$host" --no-root-password
reboot
