mod secrets "scripts/secrets.just"

[private]
default:
  @just --list --list-submodules

help:
  @just

flash device="/dev/sda" system=`nix eval --impure --raw --expr 'builtins.currentSystem'`:
  #!/usr/bin/env bash
  set -euo pipefail

  read -rp "Wi-Fi SSID (optional): " NIXOS_ISO_WIFI_SSID && export NIXOS_ISO_WIFI_SSID
  if [[ -n "$NIXOS_ISO_WIFI_SSID" ]]; then
    read -rsp "Wi-Fi password: " NIXOS_ISO_WIFI_PSK && export NIXOS_ISO_WIFI_PSK
    echo
  fi
  read -rp "Hostname (optional): " NIXOS_ISO_HOSTNAME && export NIXOS_ISO_HOSTNAME
  if [[ -n "$NIXOS_ISO_HOSTNAME" ]]; then
    read -rp "Host SSH key command: " NIXOS_ISO_HOST_KEY_CMD && export NIXOS_ISO_HOST_KEY_CMD
  fi

  nix build --impure .#nixosConfigurations.iso-"{{system}}".config.system.build.isoImage
  sudo dd if="$(ls result/iso/*.iso)" of="{{device}}" bs=4M status=progress oflag=sync

test args:
  @echo "{{args}}"
