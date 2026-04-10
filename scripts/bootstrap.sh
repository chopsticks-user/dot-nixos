#!/bin/bash

hostname = $1
usb_dev = $2

sudo mkdir /usb
sudo mount "$usb_dev" /usb
sudo cp /usb/* /etc/nixos
sudo umount /usb
sudo rm -rf /usb

sudo nix --experimental-features "nix-command flakes" \ 
  run github:nix-community/disko/latest -- --flake \
  "/etc/nixos#$hostname" --mode destroy,format,mount
  
sudo nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "/etc/nixos/hosts/$hostname/generated.nix"

sudo nixos-install --flake "/etc/nixos#$hostname" --no-root-password

reboot

