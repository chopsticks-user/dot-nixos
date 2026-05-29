{ constants, ... }:
{
  configs = {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  persist.home = {
    directories = [ "${constants.directories.home.config}/discord" ];
    files = [ ];
  };
}
