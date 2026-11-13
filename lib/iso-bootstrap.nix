# the installer's automatic bootstrap with the values `just flash` asked for; commands come in as
# arguments so tests can replace them
{
  lib,
  writeShellApplication,
  curl,
  nixos-bootstrap,
  repo,
  host,
  user,
  hostKeyCmd,
  userKeyCmd,
}:
writeShellApplication {
  name = "bootstrap";
  # the baked values are literal on purpose, so $ or backticks in a key command are not a mistake
  excludeShellChecks = [ "SC2016" ];
  runtimeInputs = [
    curl
    nixos-bootstrap
  ];
  text = ''
    repo=${lib.escapeShellArg repo}
    host=${lib.escapeShellArg host}
    user=${lib.escapeShellArg user}
    host_key_cmd=${lib.escapeShellArg hostKeyCmd}
    user_key_cmd=${lib.escapeShellArg userKeyCmd}

    _bootstrap_help() {
      echo >&2
      echo "Bootstrap failed. Fix the issue above, then either:" >&2
      echo "  1. Re-run: bootstrap" >&2
      echo "  2. Or manually:" >&2
      echo "    nixos-bootstrap $(printf '%q ' "$repo" "$host" "$host_key_cmd")" >&2
      echo "    Then reboot, log in as $user and run:" >&2
      echo "    nixos-homestrap $(printf '%q ' "$repo" "$user_key_cmd")" >&2
    }
    trap _bootstrap_help ERR

    echo "Waiting for network..."
    until curl -s --max-time 1 https://github.com &>/dev/null; do
      sleep 1
    done

    nixos-bootstrap --no-reboot "$repo" "$host" "$host_key_cmd"
    sudo nixos-enter --root /mnt -- su - "$user" -c \
      "nixos-homestrap --no-reboot $(printf '%q ' "$repo" "$user_key_cmd")"

    read -rp "Reboot now? (Y/n): " reboot_now
    if [[ "''${reboot_now,,}" != "n" ]]; then
      reboot
    fi
  '';
}
