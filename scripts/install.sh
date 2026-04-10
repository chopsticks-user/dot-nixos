#!/usr/bin/env bash

trap 'echo "error on line $LINENO, exiting..."; exit 1' ERR

arch = $1
hostname = $2
username = $3

# refer to flake.nix for the default password for all users

git clone https://github.com/chopsticks-user/dot-nixos ~/.nixos

sudo cp /mnt/etc/nixos/hardware-configuration.nix \
  "~/.nixos/hosts/$hostname/generated.nix"

cp -r ~/.nixos/wallpapers/* ~/media/wallpapers/

nh os switch -H "$hostname"
nh home switch -c "$username@$arch"

nh clean --all

reboot

