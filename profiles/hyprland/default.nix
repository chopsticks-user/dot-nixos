{
  lib,
  config,
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

      xdg.portal.config.common.default = "*";
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "hyprlang"; # todo: migrate to lua
        settings = {
          "$mod" = "SUPER";
          general = {
            gaps_out = 0;
            gaps_in = 0;
            border_size = 0;
            "col.active_border" = "rgba(88888888)";
            "col.inactive_border" = "rgba(00000088)";
            allow_tearing = true;
            resize_on_border = true;
          };
          exec-once = [
            "noctalia-shell"
            "fcitx5 -d"
          ];
          env = [
          ];
          # fix Unreal Engine's issues with hyprland and xwayland
          windowrule = [
            "no_anim on, match:class ^(UnrealEditor)$, match:title ^\\w*$"
            "no_initial_focus on, match:class ^(UnrealEditor)$, match:title ^\\w*$"
            "no_focus on, match:class ^(UnrealEditor)$, match:title ^$"
          ];
          bind =
            let
              workspaces = builtins.genList (i: i + 1) 10;
              wsKey = i: if i == 10 then "0" else toString i;
            in
            (map (i: "$mod, ${wsKey i}, workspace, ${toString i}") workspaces)
            ++ (map (i: "$mod SHIFT, ${wsKey i}, movetoworkspace, ${toString i}") workspaces)
            ++ [
              "$mod, right, workspace, e+1"
              "$mod, left, workspace, e-1"
              "$mod SHIFT, right, movetoworkspace, e+1"
              "$mod SHIFT, left, movetoworkspace, e-1"
              "$mod, M, togglespecialworkspace, magic"
              "$mod SHIFT, M, movetoworkspace, special:magic"
              "$mod, Tab, workspace, previous"
            ]
            ++ (
              let
                noctaliaCmd = "noctalia-shell ipc call";
              in
              [
                "$mod, Return, exec, kitty"
                "$mod, Q, killactive"
                "$mod, SPACE, exec, ${noctaliaCmd} launcher toggle"
                "$mod, C, exec, ${noctaliaCmd} controlCenter toggle"
                "$mod, S, exec, ${noctaliaCmd} settings toggle"
                "$mod, print, exec, ${noctaliaCmd} plugin:screen-recorder toggle"
                ", print, exec, hyprshot -z -m output -o ${constants.directories.home.screenshots}"
                "$mod, slash, exec, ${noctaliaCmd} plugin:keybind-cheatsheet toggle"
              ]
            );
        };
      };
    }
  ];
}
