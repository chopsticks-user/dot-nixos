# seanime server on the LAN, run through pkgs.seanime-server from overlays/;
# its state persists through /var/lib/private/seanime in persist.nix
{ pkgs, config, ... }:
{
  networking.firewall.allowedTCPPorts = [ pkgs.seanime-server.port ];

  systemd.services.seanime-server = {
    description = "Seanime Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.seanime-server}/bin/seanime-server";
      Restart = "always";
      DynamicUser = true;
      StateDirectory = "seanime";
      Environment = "XDG_CONFIG_HOME=/var/lib/seanime/${config.machine.directories.home.config}";
    };
  };
}
