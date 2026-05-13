{ pkgs, ... }:
{
  home.packages = with pkgs; [
  ];

  profiles = {
    core.enable = true;

    zsh.enable = true;

    ssh.enable = true;

    git = {
      enable = true;
      user = {
        name = "chopsticks-user";
        email = "frostyfrost273@gmail.com";
      };
    };

    hyprland.enable = true;

    neovim.enable = true;

    firefox.enable = true;
  };
}
