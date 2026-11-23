{ constants, ... }:
{
  options = { };

  configs = {
    nixpkgs.config.allowUnfreePackages = [
      "steam"
      "steam-unwrapped"
    ];

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
    directories = [
      "${constants.directories.home.data}/Steam"
      "${constants.directories.home.data}/gsm"
      # steamcmd and the steamclient.so that gsm's servers load live here
      ".steam"
    ];
    files = [ ];
  };
}
