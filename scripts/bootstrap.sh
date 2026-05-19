#!/usr/bin/env bash

set -euo pipefail

host=$1

config_path=$(jq -r ".directories.nixos" meta.json | sed "s|\$HOME|$HOME|")
system_identity=$(jq -r ".directories.system.identity" meta.json)

if ! jq -e ".hosts.\"$host\"" meta.json > /dev/null; then
  echo "Error: host '$host' not found in meta.json" >&2
  exit 1
fi

cd ~ || exit
rm -rf "$config_path"
git clone https://github.com/chopsticks-user/dot-nixos "$config_path"
cd "$config_path" || exit

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- --flake \
  ".#$host" --mode destroy,format,mount

echo "ssh_host_ed25519_key private key: "
iso_key=$(mktemp)
trap 'rm -f "$iso_key"' EXIT
while IFS= read -r line; do
  [ "$line" = "EOF" ] && break
  echo "$line" >> "$iso_key"
done
if ! ssh-keygen -y -f "$iso_key" > /dev/null 2>&1; then
  echo "Error: provided input is not a valid ssh private key" >&2
  exit 1
fi

sudo mkdir -p "/mnt$(dirname "$system_identity")"
sudo cp "$iso_key" "/mnt$system_identity"
sudo chmod 600 "/mnt$system_identity"
sudo chown root:root "/mnt$system_identity"
sudo ssh-keygen -y -f "/mnt$system_identity" \
  | sudo tee "/mnt${system_identity}.pub" > /dev/null
sudo chmod 644 "/mnt${system_identity}.pub"

sudo nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "./hosts/$host/generated.nix"
sudo cp /etc/nixos/install.sh /mnt/etc/nixos/
git add "./hosts/$host/generated.nix"

# todo: obtain root password via sops
sudo nixos-install --flake ".#$host" --no-root-password
reboot

