{ constants, ... }:
{
  persist.home = {
    directories = [
      ".mozilla"
      "${constants.directories.home.cache}/mozilla"
    ];
    files = [ ];
  };
}
