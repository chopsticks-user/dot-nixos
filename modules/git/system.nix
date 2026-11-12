{ config, ... }:
{
  persist.home = {
    directories = [
      "${config.machine.directories.home.config}/gh"
      "${config.machine.directories.home.state}/gh"
    ];
    files = [ ];
  };
}
