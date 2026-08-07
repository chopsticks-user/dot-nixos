{ pkgs, constants, ... }:
let
  seanimePort = 43211;
in
{
  features = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
    core = {
      wifi.home.priority = 101;
    };
  };

  networking.firewall.allowedTCPPorts = [
    seanimePort
  ];

  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
    "steamcmd"
  ];

  environment.systemPackages = with pkgs; [
    seanime
    steamcmd
  ];

  systemd.services.seanime-server = {
    description = "Seanime Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.seanime}/bin/seanime \
          --host 0.0.0.0 \
          --port ${toString seanimePort} \
          --password encryptlater
      '';
      Restart = "always";
      DynamicUser = true;
      StateDirectory = "seanime";
      Environment = "XDG_CONFIG_HOME=/var/lib/seanime/${constants.directories.home.config}";
    };
  };
}
