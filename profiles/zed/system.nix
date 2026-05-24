{ constants, ... }:
{
  persist.home = username: {
    directories = [
      "${constants.directories.home.data}/zed"
      "${constants.directories.home.cache}/zed"
    ];
    files = [ ];
  };
}
