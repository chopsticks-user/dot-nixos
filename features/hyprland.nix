{
  lib,
  pkgs,
  ...
}@args:
(lib.utils.mkFeature "hyprland" {
  options = { };

  configs =
    { lib, ... }:
    {
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
})
  args
