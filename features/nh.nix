{
  lib,
  config,
  constants,
  ...
}: let
  cfg = config.features.nh;
in {
  options.features.nh.enable = lib.mkEnableOption "nh";

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean.enable = lib.mkDefault true;
      clean.extraArgs = lib.mkDefault "--keep-since 7d --keep 8";
    };

    environment.sessionVariables = {
      NH_OS_FLAKE = constants.config-path;
      NH_HOME_FLAKE = constants.config-path;
    };
  };
}
