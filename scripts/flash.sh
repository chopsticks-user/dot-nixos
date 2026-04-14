#!/usr/bin/env bash

output_dev=${1:-/dev/sda}

cd ~/.nixos
nix build .#nixosConfigurations.iso.config.system.build.isoImage

iso=$(ls result/iso/*.iso)
sudo dd if="$iso" of="$output_dev" bs=4M status=progress oflag=sync
