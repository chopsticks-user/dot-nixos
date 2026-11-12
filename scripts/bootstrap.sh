#!/usr/bin/env bash
set -euo pipefail

no_reboot=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-reboot) no_reboot=true; shift ;;
    *) break ;;
  esac
done

host=$1
key_content=$(eval "$2")

tmp_clone=$(mktemp -d)
trap 'rm -rf "$tmp_clone"' EXIT
git clone https://github.com/chopsticks-user/dot-nixos "$tmp_clone"
export NIX_CONFIG="experimental-features = nix-command flakes"
if [ "$(nix eval --json "$tmp_clone#nixosConfigurations" --apply "c: c ? \"$host\"")" != "true" ]; then
  echo "Error: host '$host' not found in nixosConfigurations" >&2
  exit 1
fi
eval_host() { nix eval --raw "$tmp_clone#nixosConfigurations.$host.config.$1"; }
config_path_rel=$(eval_host machine.directories.nixos)
config_path=${config_path_rel/#\$HOME/$HOME}
system_identity=$(eval_host machine.directories.identity)
rm -rf "$config_path"
mkdir -p "$(dirname "$config_path")"
mv "$tmp_clone" "$config_path"
trap - EXIT
cd "$config_path" || exit

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- --flake \
  ".#$host" --mode destroy,format,mount

mnt_system_identity="/mnt/persist$system_identity"
sudo mkdir -p "$(dirname "$mnt_system_identity")"
echo "$key_content" | sudo tee "$mnt_system_identity" > /dev/null
sudo chmod 600 "$mnt_system_identity"
sudo chown root:root "$mnt_system_identity"
sudo ssh-keygen -y -f "$mnt_system_identity" \
  | sudo tee "$mnt_system_identity.pub" > /dev/null
sudo chmod 644 "$mnt_system_identity.pub"

sudo nixos-generate-config --no-filesystems --root /mnt
sudo nixos-install --flake ".#$host" --no-root-password

if [[ "$no_reboot" == false ]]; then
  read -rp "Reboot now? (Y/n): " reboot_now
  if [[ "${reboot_now,,}" != "n" ]]; then
    reboot
  fi
fi
