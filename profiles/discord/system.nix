{ constants, ... }:
{
  persist.home = {
    directories = [ "${constants.directories.home.config}/discord" ];
    files = [ ];
  };
}
