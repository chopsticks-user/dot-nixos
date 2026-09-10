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
        playerctl
        brightnessctl
      ];

      programs.kitty = {
        enable = true;
        font = {
          name = "FiraCode Nerd Font Mono";
          size = 10;
        };
        settings = {
          background_opacity = "0.6";
          confirm_os_window_close = 0;
          window_padding_width = 5;
          disable_ligatures = "never";
        };
      };

      xdg.portal.config.common.default = "*";
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        settings = {
          mod._var = "SUPER";

          config = {
            general = {
              gaps_in = 0;
              gaps_out = 0;
              border_size = 0;
              "col.active_border" = "rgba(88888888)";
              "col.inactive_border" = "rgba(00000088)";
              allow_tearing = true;
              resize_on_border = true;
            };
            input.kb_options = "caps:escape_shifted_capslock";
          };

          on = {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''
                function()
                  hl.exec_cmd("noctalia")
                  hl.exec_cmd("fcitx5 -d")
                end
              '')
            ];
          };

          window_rule = [
            {
              no_anim = true;
              match = {
                class = "^(UnrealEditor)$";
                title = "^\\w*$";
              };
            }
            {
              no_initial_focus = true;
              match = {
                class = "^(UnrealEditor)$";
                title = "^\\w*$";
              };
            }
            {
              no_focus = true;
              match = {
                class = "^(UnrealEditor)$";
                title = "^$";
              };
            }
          ];

          bind =
            let
              workspaces = builtins.genList (i: i + 1) 10;
              wsKey = i: if i == 10 then "0" else toString i;
              noctaliaCmd = "noctalia msg";
            in
            lib.concatMap (i: [
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + ${wsKey i}"'')
                  (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "${toString i}" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + ${wsKey i}"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "${toString i}" })'')
                ];
              }
            ]) workspaces
            ++ [
              # Focus / move between workspaces
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + right"'')
                  (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "right" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + left"'')
                  (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "left" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + up"'')
                  (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "up" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + down"'')
                  (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "down" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + right"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "e+1" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + left"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "e-1" })'')
                ];
              }

              # General window management
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + Return"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("kitty")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + Q"'')
                  (lib.generators.mkLuaInline "hl.dsp.window.close()")
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + E"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("open .")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + V"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + P"'')
                  (lib.generators.mkLuaInline "hl.dsp.window.pseudo()")
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + J"'')
                  (lib.generators.mkLuaInline ''hl.dsp.layout("togglesplit")'')
                ];
              }

              # Special workspace
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + S"'')
                  (lib.generators.mkLuaInline ''hl.dsp.workspace.toggle_special("magic")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SHIFT + S"'')
                  (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "special:magic" })'')
                ];
              }

              # Workspace cycling
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + mouse_down"'')
                  (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "e+1" })'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + mouse_up"'')
                  (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "e-1" })'')
                ];
              }

              # Mouse bindings
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + mouse:272"'')
                  (lib.generators.mkLuaInline "hl.dsp.window.drag()")
                ];
                mouse = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + mouse:273"'')
                  (lib.generators.mkLuaInline "hl.dsp.window.resize()")
                ];
                mouse = true;
              }

              # Audio
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioRaiseVolume"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'')
                ];
                locked = true;
                repeating = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioLowerVolume"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')
                ];
                locked = true;
                repeating = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioMute"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
                ];
                locked = true;
                repeating = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioMicMute"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')
                ];
                locked = true;
                repeating = true;
              }

              # Brightness
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86MonBrightnessUp"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+")'')
                ];
                locked = true;
                repeating = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86MonBrightnessDown"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-")'')
                ];
                locked = true;
                repeating = true;
              }

              # Media
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioNext"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'')
                ];
                locked = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioPause"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
                ];
                locked = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioPlay"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
                ];
                locked = true;
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"XF86AudioPrev"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'')
                ];
                locked = true;
              }

              # Noctalia
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + SPACE"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${noctaliaCmd} panel-toggle launcher")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + print"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${noctaliaCmd} plugin noctalia/screen-recorder:service all toggle")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''"print"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot -z -m output -o <constants.directories.home.screenshots>")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + slash"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${noctaliaCmd} plugin noctalia/keybind-cheatsheet:service all toggle")'')
                ];
              }
              {
                _args = [
                  (lib.generators.mkLuaInline ''mod .. " + M"'')
                  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${noctaliaCmd} panel-toggle session")'')
                ];
              }
            ];
        };
      };
    }
  ];
}
