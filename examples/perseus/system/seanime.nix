# seanime server on the LAN; its state persists through /var/lib/private/seanime in persist.nix
{ pkgs, config, ... }:
let
  port = 43211;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  systemd.services.seanime-server = {
    description = "Seanime Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.seanime}/bin/seanime \
          --host 0.0.0.0 \
          --port ${toString port} \
          --password encryptlater
      '';
      Restart = "always";
      DynamicUser = true;
      StateDirectory = "seanime";
      Environment = "XDG_CONFIG_HOME=/var/lib/seanime/${config.machine.directories.home.config}";
    };
  };
}
