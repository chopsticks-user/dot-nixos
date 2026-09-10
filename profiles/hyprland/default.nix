{
  lib,
  pkgs,
  inputs,
  constants,
  ...
}@args:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options = { };

  configs = lib.mkMerge [
    (lib.mergeImports [
      ./applications.nix
      ./noctalia.nix
    ] args)
    {
      home.packages = with pkgs; [
        hyprshot
      ];
      xdg = {
        portal.config.common.default = "*";
        configFile."hypr/hyprland.lua".source = ./hyprland.lua;
      };
      wayland.windowManager.hyprland.enable = true;
    }
  ];
}
