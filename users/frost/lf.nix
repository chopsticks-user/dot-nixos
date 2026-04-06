{ ... }: {
  programs.lf = {
    enable = true;
    settings = {
      preview = true;
      hidden = true;
      dirfirst = true;
    };
    keybindings = {
      "\\\"" = "";
    };
  };
}
