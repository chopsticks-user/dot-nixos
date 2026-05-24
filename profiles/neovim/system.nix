{ constants, ... }:
{
  persist.home = username: {
    directories = [ "${constants.directories.home.data}/nvf" ];
    files = [ ];
  };
}
