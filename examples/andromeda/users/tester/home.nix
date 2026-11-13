{ ... }:
{
  modules = {
    zsh.enable = true;
    ssh.enable = true;
    git = {
      enable = true;
      identityFromSecrets = true;
    };
    hyprland.enable = true;
    neovim.enable = true;
    firefox.enable = true;
    zed.enable = true;
  };
}
