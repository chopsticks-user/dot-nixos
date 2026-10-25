{
  lib,
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
      "${constants.directories.home.state}/wireplumber"
      "${constants.directories.home.cache}/noctalia"
    ];
    files = [ ];
  };
}
