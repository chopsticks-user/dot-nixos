{ ... }:
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

    # todo: enable cpu-governed optimizations
    # services.gamemode.enable = true;
  };
}
