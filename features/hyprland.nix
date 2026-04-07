{ lib, config, pkgs, ... }:
let
  cfg = config.features.hyprland;
in {
  options.features.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = lib.mkDefault true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      config.common.default = "*";
    };
  };
}
