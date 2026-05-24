{ constants, ... }:
{
  persist.home = username: {
    directories = [ "${constants.directories.home.config}/discord" ];
    files = [ ];
  };
}
