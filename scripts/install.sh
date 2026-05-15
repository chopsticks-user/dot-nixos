#!/usr/bin/env bash

trap 'echo "error on line $LINENO, exiting..."; exit 1' ERR

arch=$1
host=$2
username=$3

# refer to flake.nix for the default password for all users

rm -rf ~/.config/nixos
git clone https://github.com/chopsticks-user/dot-nixos ~/.config/nixos
cd ~/.config/nixos || exit

cp /etc/nixos/hardware-configuration.nix \
  "./hosts/$host/generated.nix"
git add .

nh home switch -c "$username@$arch"

nh clean all

reboot

