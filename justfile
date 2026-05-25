mod secrets "scripts/secrets.just"

[private]
default:
  @just --list --list-submodules

help:
  @just

flash device="/dev/sda" system=`nix eval --impure --raw --expr 'builtins.currentSystem'`:
  #!/usr/bin/env bash
  set -euo pipefail

  read -rp "Set up automated bootstrapping? (y/N): " NIXOS_ISO_AUTO_BOOTSTRAP && export NIXOS_ISO_AUTO_BOOTSTRAP
  if [[ "${NIXOS_ISO_AUTO_BOOTSTRAP,,}" == "y" ]]; then
    read -rp "Set up Wi-Fi? (y/N): " NIXOS_ISO_SETUP_WIFI && export NIXOS_ISO_SETUP_WIFI
    if [[ "${NIXOS_ISO_SETUP_WIFI,,}" == "y" ]]; then
      read -rp "Wi-Fi SSID: " NIXOS_ISO_WIFI_SSID && export NIXOS_ISO_WIFI_SSID
      read -rsp "Wi-Fi password: " NIXOS_ISO_WIFI_PSK && export NIXOS_ISO_WIFI_PSK
      [[ -t 0 ]] && echo
    fi
    read -rp "Hostname: " NIXOS_ISO_HOSTNAME && export NIXOS_ISO_HOSTNAME
    read -rp "Username: " NIXOS_ISO_USERNAME && export NIXOS_ISO_USERNAME
    read -rp "Host SSH key command: " NIXOS_ISO_HOST_KEY_CMD && export NIXOS_ISO_HOST_KEY_CMD
    read -rp "User SSH key command: " NIXOS_ISO_USER_KEY_CMD && export NIXOS_ISO_USER_KEY_CMD
  fi

  nix build --impure .#nixosConfigurations.iso-"{{system}}".config.system.build.isoImage
  sudo dd if="$(ls result/iso/*.iso)" of="{{device}}" bs=4M status=progress oflag=sync
  echo "Warning: sensitive values are stored in the Nix store. Run 'rm -f result && nix store gc' to remove them, or manually delete with 'nix store delete \$(readlink -f result)' before removing the symlink."
test args:
  @echo "{{args}}"
