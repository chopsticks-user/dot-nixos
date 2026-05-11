{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profiles.obs;
in
{
  options.profiles.obs = {
    enable = lib.mkEnableOption "obs";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [
      ];
    };
  };
}
