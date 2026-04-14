#!/usr/bin/env bash

trap 'echo "error on line $LINENO, exiting..."; exit 1' ERR

output_dev=${1:-/dev/sda}

cd ~/.nixos
nix build .#nixosConfigurations.iso.config.system.build.isoImage

iso=$(ls result/iso/*.iso)
sudo dd if="$iso" of="$output_dev" bs=4M status=progress oflag=sync
