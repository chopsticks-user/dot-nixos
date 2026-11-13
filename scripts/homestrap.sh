#!/usr/bin/env bash
# runs as the user on the installed machine: clones the machine repository to the flake checkout
# and places the user key, so this user's secrets decrypt from the next boot on
set -euo pipefail

usage() {
  echo "usage: nixos-homestrap [--no-reboot] <repo-url> <user-key-command>" >&2
  exit 1
}

no_reboot=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-reboot)
      no_reboot=true
      shift
      ;;
    *) break ;;
  esac
done
[[ $# -eq 2 ]] || usage

repo=$1
config_path="${NIXOS_FLAKE_DIR:-$HOME/.config/nixos}"
home_identity="$HOME/${NIXOS_HOME_IDENTITY:-.ssh/id_ed25519}"

if [ -e "$config_path" ]; then
  echo "$config_path exists, not cloning"
else
  mkdir -p "$(dirname "$config_path")"
  git clone "$repo" "$config_path"
fi

if [ -f "$home_identity" ]; then
  echo "$home_identity exists, not replacing it"
else
  key_content=$(eval "$2")
  mkdir -p "$(dirname "$home_identity")"
  chmod 700 "$(dirname "$home_identity")"
  (umask 077 && echo "$key_content" >"$home_identity")
  ssh-keygen -y -f "$home_identity" >"$home_identity.pub"
  chmod 644 "$home_identity.pub"
fi

if [[ "$no_reboot" == false ]]; then
  read -rp "Reboot now? (Y/n): " reboot_now
  if [[ "${reboot_now,,}" != "n" ]]; then
    reboot
  fi
fi
