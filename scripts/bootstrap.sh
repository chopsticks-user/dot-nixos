#!/bin/bash

hostname = $1

cd ~/.nixos

sudo nix --experimental-features "nix-command flakes" \ 
  run github:nix-community/disko/latest -- --flake \
  ".#$hostname" --mode destroy,format,mount
  
sudo nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "./hosts/$hostname/generated.nix"

sudo nixos-install --flake ".#$hostname" --no-root-password

reboot

