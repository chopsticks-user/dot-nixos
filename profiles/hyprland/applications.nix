{
  pkgs,
  constants,
  ...
}:
{
  programs = {
    superfile.enable = true;
    rmpc.enable = true;
    mpv.enable = true;
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
  };

  services.mpd = {
    enable = true;
    musicDirectory = "${constants.directories.home.music}";
    network = {
      listenAddress = "any";
      startWhenNeeded = true;
    };
  };

  profiles.open = with pkgs; {
    enable = true;
    html = firefox;
    image = imv;
    pdf = {
      package = zathura;
      desktopEntry = "org.pwmt.zathura";
    };
    video = mpv;
    directory = {
      package = superfile;
      desktopEntry = {
        name = "Superfile";
        comment = "Terminal file manager";
        exec = "${pkgs.writeShellScriptBin "superfile-open" ''
          ''$TERMINAL ${pkgs.superfile}/bin/superfile "$@"
        ''}/bin/superfile-open %u";
        terminal = false;
      };
    };
  };
}
