{ constants, ... }:
{
  persist.home = {
    directories = [
      "${constants.directories.home.config}/gh"
      "${constants.directories.home.state}/gh"
    ];
    files = [ ];
  };
}
