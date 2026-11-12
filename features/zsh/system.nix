{ config, ... }:
{
  persist.home = {
    directories = [ "${config.machine.directories.home.config}/zsh" ];
    files = [ ".zsh_history" ];
  };
}
