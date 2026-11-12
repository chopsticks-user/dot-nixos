{ config, ... }:
{
  persist.home = {
    directories = [ "${config.machine.directories.home.data}/nvf" ];
    files = [ ];
  };
}
