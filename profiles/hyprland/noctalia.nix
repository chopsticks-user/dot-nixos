{ constants, ... }:
{
  #  xdg.configFile."noctalia/plugins.json".force = true;

  programs.noctalia = {
    enable = true;
    settings = {
      plugins = {
        autoUpdate = false;
        notifyUpdates = true;
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states =
          let
            pluginStates = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          in
          {
            keybind-cheatsheet = pluginStates;
            screen-recorder = pluginStates;
          };
        version = 2;
      };
      pluginSettings = {
        screen-recorder = {
          outputFolder = "${constants.directories.home.screencasts}";
        };
      };
    };
  };
}
