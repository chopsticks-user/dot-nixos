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
      jq
      git
    ];
    text = builtins.readFile ../scripts/bootstrap.sh;
  };
  nixosHomestrapPkg = pkgs.writeShellApplication {
    name = "nixos-homestrap";
    runtimeInputs = with pkgs; [
      home-manager
      openssh
      jq
      git
      curl
    ];
    text = builtins.readFile ../scripts/install.sh;
  };
  bootstrapPkg = pkgs.writeShellApplication {
    name = "bootstrap";
    runtimeInputs = [
      nixosBootstrapPkg
      nixosHomestrapPkg
    ];
    text =
      let
        hostname = builtins.getEnv "NIXOS_ISO_HOSTNAME";
        hostKeyCmd = builtins.getEnv "NIXOS_ISO_HOST_KEY_CMD";
        username = builtins.getEnv "NIXOS_ISO_USERNAME";
        userKeyCmd = builtins.getEnv "NIXOS_ISO_USER_KEY_CMD";
        escapedHostKeyCmd = builtins.replaceStrings [ "'" ] [ "\\'" ] hostKeyCmd;
        escapedUserKeyCmd = builtins.replaceStrings [ "'" ] [ "\\'" ] userKeyCmd;
      in
      ''
        _bootstrap_help() {
          printf "\n" >&2
          printf "Bootstrap failed. Fix the issue above, then either:\n" >&2
          printf "  1. Re-run: bootstrap\n" >&2
          printf "  2. Or manually:\n" >&2
          printf "    nixos-bootstrap ${hostname} ${escapedHostKeyCmd}\n" >&2
          printf "    Then reboot and log in as ${username}, then run:\n" >&2
          printf "    nixos-homestrap ${escapedUserKeyCmd}\n" >&2
        }
        trap _bootstrap_help ERR
        nixos-bootstrap --no-reboot "${hostname}" "${hostKeyCmd}"
        sudo nixos-enter --root /mnt -- su - "${username}" -c "nixos-homestrap '${userKeyCmd}'"
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
      nixosHomestrapPkg
    ]
    ++ lib.optional autoBootstrap bootstrapPkg;

  systemd.services.iso-auto-bootstrap = lib.mkIf autoBootstrap {
    description = "Automated NixOS bootstrap";
    after = [
      "network-online.target"
      "NetworkManager-wait-online.service"
    ];
    wants = [
      "network-online.target"
      "NetworkManager-wait-online.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${bootstrapPkg}/bin/bootstrap";
    };
  };
}
