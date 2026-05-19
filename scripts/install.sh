#!/usr/bin/env bash

set -euo pipefail

username=$(whoami)
arch=$(nix eval --impure --raw --expr 'builtins.currentSystem')
config_path=$(jq -r ".directories.nixos" meta.json | sed "s|\$HOME|$HOME|")

rm -rf "$config_path"
git clone https://github.com/chopsticks-user/dot-nixos "$config_path"
cd "$config_path" || exit

nh home switch -c "$username@$arch"
nh clean all --optimise
reboot
