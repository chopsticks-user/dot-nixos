{ constants, ... }:
{
  persist.home = username: {
    directories = [ "${constants.directories.home.config}/gh" ];
    files = [ ];
  };
}
