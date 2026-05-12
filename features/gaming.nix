{
  config,
  lib,
  ...
}:

{
  options.features.gaming = {
    enable = lib.mkEnableOption "gaming";
  };

  config =
    let
      cfg = config.features.gaming;
    in
    lib.mkIf cfg.enable {
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
}
