# this file belongs to nixosConfigurations
{ ... }:
{
  systemProfiles = {
    ssh.enable = true;
    hyprland.enable = true;
    zsh.enable = true;
    git.enable = true;
    neovim.enable = true;
    firefox.enable = true;
    zed.enable = true;
  };
}
