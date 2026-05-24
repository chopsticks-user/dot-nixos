{ constants, ... }:
{
  persist.home = {
    directories = [
      "${constants.directories.home.data}/zed"
      "${constants.directories.home.cache}/zed"
    ];
    files = [ ];
  };
}
