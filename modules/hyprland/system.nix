{
  lib,
  config,
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
      "${config.machine.directories.home.config}/hypr"
      "${config.machine.directories.home.config}/noctalia"
      "${config.machine.directories.home.data}/hyprland"
      "${config.machine.directories.home.state}/wireplumber"
      "${config.machine.directories.home.cache}/noctalia"
    ];
    files = [ ];
  };
}
