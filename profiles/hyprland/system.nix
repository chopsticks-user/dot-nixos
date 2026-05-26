{
  lib,
  pkgs,
  constants,
  ...
}:
{
  options = { };

  configs = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = lib.mkDefault true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      config.common.default = "*";
    };

    environment.loginShellInit = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
       start-hyprland
      fi
    '';
  };

  persist.home = {
    directories = [
      "${constants.directories.home.config}/hypr"
      "${constants.directories.home.config}/noctalia"
      "${constants.directories.home.data}/hyprland"
      "${constants.directories.home.data}/mpd"
      "${constants.directories.home.data}/superfile"
      "${constants.directories.home.state}/wireplumber"
      "${constants.directories.home.cache}/noctalia"
    ];
    files = [ ];
  };
}
