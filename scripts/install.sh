#!/bin/bash

sudo mkdir /usb
sudo mount /dev/sda3 /usb
sudo cp /usb/* /etc/nixos

sudo nix --experimental-features "nix-command flakes" \ 
  run github:nix-community/disko/latest -- --flake \
  /etc/nixos#andromeda --mode destroy,format,mount
  
sudo nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  /etc/nixos/hosts/andromeda/generated.nix

sudo nixos-install --flake /etc/nixos#hostname --no-root-password

reboot

# refer to flake.nix for the default password for all users

sudo mkdir -p /mnt/usb
sudo mount /dev/sda3 /mnt/usb
mkdir ~/.nixos
sudo -r cp /mnt/usb/* ~/.nixos/
sudo umount /mnt/usb
sudo rm -rf /mnt/usb

nh os switch -H andromeda
nh home switch -c frost@x86_64-linux

