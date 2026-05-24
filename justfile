mod secrets "scripts/secrets.just"

[private]
default:
  @just --list --list-submodules

help:
  @just

flash device="/dev/sda" system=`nix eval --impure --raw --expr 'builtins.currentSystem'`:
  #!/usr/bin/env bash
  set -euo pipefail

  read -rp "Wi-Fi SSID (optional): " WIFI_SSID && export WIFI_SSID
  if [[ -n "$WIFI_SSID" ]]; then
    read -rsp "Wi-Fi password: " WIFI_PSK && export WIFI_PSK
    echo
  fi

  nix build .#nixosConfigurations.iso-"{{system}}".config.system.build.isoImage
  sudo dd if="$(ls result/iso/*.iso)" of="{{device}}" bs=4M status=progress oflag=sync

test args:
  @echo "{{args}}"
