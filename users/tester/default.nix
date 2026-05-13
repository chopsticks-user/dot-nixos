{ pkgs, constants, ... }:
{
  home.packages = with pkgs; [
  ];

  profiles = {
    core.enable = true;

    zsh.enable = true;

    ssh.enable = true;

    git = {
      enable = true;
      inherit (constants.profiles.git) user;
    };

    hyprland.enable = true;

    neovim.enable = true;

    firefox.enable = true;
  };
}
