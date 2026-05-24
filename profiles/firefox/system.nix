{ constants, ... }:
{
  persist.home = username: {
    directories = [
      ".mozilla"
      "${constants.directories.home.cache}/mozilla"
    ];
    files = [ ];
  };
}
