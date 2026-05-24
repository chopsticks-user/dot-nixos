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

  networking.wireless = {
    enable = true;
    networks =
      let
        ssid = builtins.getEnv "NIXOS_ISO_WIFI_SSID";
      in
      if ssid != "" then { ${ssid}.psk = builtins.getEnv "NIXOS_ISO_WIFI_PSK"; } else { };
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
        text = ''
          ${builtins.readFile ../scripts/bootstrap.sh} ''${NIXOS_ISO_HOSTNAME:+$NIXOS_ISO_HOSTNAME ''${NIXOS_ISO_HOST_SSH_KEY:-}}
        '';
      })
    ];
  };
}
