{
  modulesPath,
  pkgs,
  ...
}:
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
            psk = builtins.getEnv "NIXOS_ISO_WIFI_PSK";
          in
          if ssid != "" then
            {
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
                  inherit psk;
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };
            }
          else
            { };
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      git
      vim

      (pkgs.writeShellApplication {
        name = "nixos-bootstrap";
        runtimeInputs = [
          just
          openssh
          jq
        ];
        text =
          let
            hostname = builtins.getEnv "NIXOS_ISO_HOSTNAME";
          in
          ''
            ${builtins.readFile ../scripts/bootstrap.sh} ${
              if hostname != "" then "${hostname} ${builtins.getEnv "NIXOS_ISO_HOST_KEY_CMD"}" else ""
            }
          '';
      })
    ];
  };
}
