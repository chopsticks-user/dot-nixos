{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.caelestia.homeManagerModules.default
  ];

  options = { };

  configs = {
    nixpkgs.config.allowUnfreePackages = [
      "harmonoid"
    ];

    home.packages = with pkgs; [
      hyprshot
      playerctl
      brightnessctl
    ];

    features.open = with pkgs; {
      enable = true;
      html = firefox;
      image = {
        package = kdePackages.gwenview;
        desktopEntry = "org.kde.gwenview";
      };
      pdf = {
        package = kdePackages.okular;
        desktopEntry = "org.kde.okular";
      };
      video = {
        package = haruna;
        desktopEntry = "org.kde.haruna";
      };
      audio = {
        package = harmonoid;
        desktopEntry = "org.kde.harmonoid";
      };
      directory = {
        package = kdePackages.dolphin;
        desktopEntry = "org.kde.dolphin";
      };
    };

    programs = {
      kitty = {
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

      noctalia = {
        enable = true;
        settings = ./noctalia-config.toml;
      };
    };

    xdg.configFile."hypr/hyprland.lua".force = true;
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
            # kitty requests maximize on start, which covers other tiled windows
            suppress_event = "maximize";
            match.class = "^(kitty)$";
          }
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
                (lib.generators.mkLuaInline ''mod .. " + XF86AudioRaiseVolume"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+")'')
              ];
              locked = true;
              repeating = true;
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + XF86AudioLowerVolume"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-")'')
              ];
              locked = true;
              repeating = true;
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + XF86AudioMute"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')
              ];
              locked = true;
            }
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
            {
              _args = [
                (lib.generators.mkLuaInline ''"SUPER_L"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${noctaliaCmd} panel-toggle launcher")'')
                # fire on release so SUPER + <key> combos don't open the launcher
                { release = true; }
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''"Print"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot -z -m output -o ${config.user.directories.screenshots}")'')
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + l"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${noctaliaCmd} panel-toggle session")'')
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + m"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${noctaliaCmd} settings-toggle")'')
              ];
            }
          ];
      };
    };
  };
}
