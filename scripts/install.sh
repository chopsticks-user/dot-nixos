#!/bin/bash

arch = $1
hostname = $2
username = $3
usb_dev = $4

# refer to flake.nix for the default password for all users

sudo mkdir -p /mnt/usb
sudo mount "$usb_dev" /mnt/usb
mkdir ~/.nixos
sudo -r cp /mnt/usb/* ~/.nixos/
sudo umount /mnt/usb
sudo rm -rf /mnt/usb

sudo cp /etc/nixos/hardware-configuration.nix \
  "~/.nixos/hosts/$hostname/generated.nix"

cp -r ~/.nixos/wallpapers/* ~/media/wallpapers/

nh os switch -H "$hostname"
nh home switch -c "$username@$arch"

reboot

