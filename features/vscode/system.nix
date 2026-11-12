{ config, ... }:
{
  persist.home = {
    directories = [
      # sign-ins, workspace state and extension globalStorage live here
      "${config.machine.directories.home.config}/Code"
    ];
    files = [ ];
  };
}
