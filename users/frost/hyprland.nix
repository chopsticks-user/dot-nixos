{ ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        gaps_out = 5;
        gaps_in = 5;
      };
      exec-once = [
        "noctalia-shell"
      ];
      bind = [
        "SUPER, Return, exec, kitty"
        "SUPER, Q, killactive"
        "SUPER, SPACE, exec, noctalia-shell ipc call launcher toggle"
        "SUPER, C, exec, noctalia-shell ipc call controlCenter toggle"
        "SUPER, S, exec, noctalia-shell ipc call settings toggle"
      ];
    };
  };
}
