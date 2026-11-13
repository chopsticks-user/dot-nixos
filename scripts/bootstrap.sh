#!/usr/bin/env bash
# runs on the installer: partitions the disk with the machine's disko layout, places the host key
# where sops reads it and installs the machine from its repository
set -euo pipefail

usage() {
  echo "usage: nixos-bootstrap [--no-reboot] <repo-url> <host> <host-key-command>" >&2
  exit 1
}

no_reboot=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-reboot)
      no_reboot=true
      shift
      ;;
    *) break ;;
  esac
done
[[ $# -eq 3 ]] || usage

repo=$1
host=$2
key_content=$(eval "$3")

export NIX_CONFIG="experimental-features = nix-command flakes"
flake=$(mktemp -d)
git clone "$repo" "$flake"
if [ "$(nix eval --json "$flake#nixosConfigurations" --apply "c: c ? \"$host\"")" != "true" ]; then
  echo "error: $repo has no nixosConfigurations.$host" >&2
  exit 1
fi

# sudo drops NIX_CONFIG
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --flake "$flake#$host" --mode destroy,format,mount

# under /persist on impermanence machines, because sops decrypts before it is bind-mounted
key_path=/mnt$(nix eval --raw "$flake#nixosConfigurations.$host.config.sops.age.sshKeyPaths" --apply builtins.head)
sudo mkdir -p "$(dirname "$key_path")"
echo "$key_content" | sudo tee "$key_path" >/dev/null
sudo chmod 600 "$key_path"
sudo chown root:root "$key_path"
sudo ssh-keygen -y -f "$key_path" | sudo tee "$key_path.pub" >/dev/null
sudo chmod 644 "$key_path.pub"

# a reference copy in /mnt/etc/nixos to compare against the committed hardware/generated.nix
sudo nixos-generate-config --no-filesystems --root /mnt
sudo nixos-install --flake "$flake#$host" --no-root-password

if [[ "$no_reboot" == false ]]; then
  read -rp "Reboot now? (Y/n): " reboot_now
  if [[ "${reboot_now,,}" != "n" ]]; then
    reboot
  fi
fi
