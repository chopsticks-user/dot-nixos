{ config, ... }:
{
  options = { };

  allowUnfree = [
    "steam"
    "steam-unwrapped"
  ];

  configs = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
      gamemode = {
        enable = true;
      };
    };
  };

  persist.home = {
    directories = [ "${config.machine.directories.home.data}/Steam" ];
    files = [ ];
  };
}
