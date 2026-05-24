{ constants, ... }:
{
  persist.home = {
    directories = [ "${constants.directories.home.config}/zsh" ];
    files = [ ".zsh_history" ];
  };
}
