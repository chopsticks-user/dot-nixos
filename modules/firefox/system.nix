{ config, ... }:
{
  persist.home = {
    directories = [
      ".mozilla"
      "${config.machine.directories.home.cache}/mozilla"
    ];
    files = [ ];
  };
}
