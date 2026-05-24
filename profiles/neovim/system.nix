{ constants, ... }:
{
  persist.home = {
    directories = [ "${constants.directories.home.data}/nvf" ];
    files = [ ];
  };
}
