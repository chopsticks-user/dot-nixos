{
  modulesPath,
  pkgs,
  lib,
  ...
}:
let
  autoBootstrap = builtins.getEnv "NIXOS_ISO_AUTO_BOOTSTRAP" == "y";
  nixosBootstrapPkg = pkgs.writeShellApplication {
    name = "nixos-bootstrap";
    runtimeInputs = with pkgs; [
      openssh
      git
    ];
    text = builtins.readFile ../scripts/bootstrap.sh;
  };
  # values baked in by `just flash`; the installed machine runs its own nixos-homestrap
  bootstrapPkg = pkgs.writeShellApplication {
    name = "bootstrap";
    runtimeInputs = [
      pkgs.curl
      nixosBootstrapPkg
    ];
    text =
      let
        env = name: lib.escapeShellArg (builtins.getEnv "NIXOS_ISO_${name}");
      in
      ''
        repo=${env "REPO"}
        host=${env "HOSTNAME"}
        user=${env "USERNAME"}
        host_key_cmd=${env "HOST_KEY_CMD"}
        user_key_cmd=${env "USER_KEY_CMD"}

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
  };
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.zfs.forceImportRoot = false;

  networking = {
    networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [ ];
        profiles =
          let
            ssid = builtins.getEnv "NIXOS_ISO_WIFI_SSID";
          in
          lib.optionalAttrs (builtins.getEnv "NIXOS_ISO_SETUP_WIFI" == "y") {
            wifi = {
              connection = {
                id = ssid;
                type = "wifi";
              };
              wifi = {
                mode = "infrastructure";
                inherit ssid;
              };
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = builtins.getEnv "NIXOS_ISO_WIFI_PSK";
              };
              ipv4.method = "auto";
              ipv6.method = "auto";
            };
          };
      };
    };
  };

  environment.systemPackages =
    with pkgs;
    [
      git
      vim
      openssh
      jq
      just

      nixosBootstrapPkg
    ]
    ++ lib.optional autoBootstrap bootstrapPkg;

  environment.loginShellInit = lib.mkIf autoBootstrap ''
    if [ -z "$NIXOS_ISO_BOOTSTRAP_DONE" ]; then
      export NIXOS_ISO_BOOTSTRAP_DONE=1
      bootstrap
    fi
  '';
}
