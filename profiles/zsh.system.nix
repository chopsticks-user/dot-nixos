{ ... }:
{
  persist.home = username: {
    directories = [ ".config/zsh" ];
    files = [ ".zsh_history" ];
  };
}
