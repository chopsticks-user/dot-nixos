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
  bootstrapPkg = pkgs.callPackage ./iso-bootstrap.nix (
    let
      env = name: builtins.getEnv "NIXOS_ISO_${name}";
    in
    {
      nixos-bootstrap = nixosBootstrapPkg;
      repo = env "REPO";
      host = env "HOSTNAME";
      user = env "USERNAME";
      hostKeyCmd = env "HOST_KEY_CMD";
      userKeyCmd = env "USER_KEY_CMD";
    }
  );
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
