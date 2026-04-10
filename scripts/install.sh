#!/usr/bin/env bash

trap 'echo "error on line $LINENO, exiting..."; exit 1' ERR

arch=$1
host=$2
username=$3

# refer to flake.nix for the default password for all users

cp /etc/nixos/hardware-configuration.nix \
  "$HOME/.nixos/hosts/$host/generated.nix"
git -C ~/.nixos add "~/.nixos/hosts/$host/generated.nix"

cp -r ~/.nixos/wallpapers/* ~/media/wallpapers/

nh os switch -H "$host"
nh home switch -c "$username@$arch"

nh clean --all

reboot

