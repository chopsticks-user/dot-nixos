{ config, ... }:
{
  persist.home = {
    directories = [
      "${config.machine.directories.home.config}/zsh"
      "${config.machine.directories.home.data}/zoxide"
    ];
    files = [ ".zsh_history" ];
  };
}
