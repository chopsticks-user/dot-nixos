{...}: {
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
}
