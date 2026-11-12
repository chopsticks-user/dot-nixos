{ constants, ... }:
{
  persist.home = {
    directories = [
      # sign-ins, workspace state and extension globalStorage live here
      "${constants.directories.home.config}/Code"
    ];
    files = [ ];
  };
}
