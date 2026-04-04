{ ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      general = {
        gaps_out = 5;
        gaps_in = 5;
      };
      exec-once = [
        "noctalia-shell"
      ];
      bind = let
        workspaces = builtins.genList (i: i + 1) 10;
      wsKey = i: if i == 10 then "0" else toString i;
      wsBind = map (i: "$mod, ${wsKey i}, workspace, ${toString i}")
        workspaces;
      moveBind = map (i: "$mod SHIFT, ${wsKey i}, movetoworkspace, ${toString i}") 
        workspaces;
      noctaliaCmd = "noctalia-shell ipc call";
      in wsBind ++ moveBind
        ++ [
          "$mod, right, workspace, e+1"
          "$mod, left, workspace, e-1"
          "$mod SHIFT, right, movetoworkspace, e+1"
          "$mod SHIFT, left, movetoworkspace, e-1"
          "$mod, M, togglespecialworkspace, magic"
          "$mod SHIFT, M, movetoworkspace, special:magic"
          "$mod, Tab, workspace, previous"
        ]
        ++ [
          "$mod, Return, exec, kitty"
          "$mod, Q, killactive"
          "$mod, SPACE, exec, ${noctaliaCmd} launcher toggle"
          "$mod, C, exec, ${noctaliaCmd} controlCenter toggle"
          "$mod, S, exec, ${noctaliaCmd} settings toggle"
        ];
    };
  };
         }
