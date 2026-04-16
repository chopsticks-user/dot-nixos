{
  lib,
  config,
  constants,
  ...
}: let
  cfg = config.profiles.core;
in {
  imports = [
    ./fonts.nix
    ./xbds.nix
    ./zoxide.nix
  ];

  options.profiles.core = {
    enable = lib.mkEnableOption "core";
  };

  config = lib.mkIf cfg.enable {
    home = {
      stateVersion = "26.05";
      inherit (constants) username;
      homeDirectory = constants.home-dir;
    };
  };
}
