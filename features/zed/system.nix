{ config, ... }:
{
  persist.home = {
    directories = [
      "${config.machine.directories.home.data}/zed"
      "${config.machine.directories.home.cache}/zed"
    ];
    files = [ ];
  };
}
