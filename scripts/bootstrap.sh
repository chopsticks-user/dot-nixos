#!/usr/bin/env bash

trap 'echo "error on line $LINENO, exiting..."; exit 1' ERR

host=$1

cd ~
git clone https://github.com/chopsticks-user/dot-nixos .nixos
cd .nixos

sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- --flake \
  ".#$host" --mode destroy,format,mount
  
sudo nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "./hosts/$host/generated.nix"
git add "./hosts/$host/generated.nix"

sudo nixos-install --flake ".#$host" --no-root-password

reboot

