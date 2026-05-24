{ constants, ... }:
{
  persist.home = username: {
    directories = [ "${constants.directories.home.config}/zsh" ];
    files = [ ".zsh_history" ];
  };
}
