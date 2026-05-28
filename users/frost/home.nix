{ pkgs, ... }:
{
  nixpkgs.config.allowUnfreePackages = [
    "rider"
    "clion"
  ];

  home.packages = with pkgs; [
    jetbrains.rider
    jetbrains.clion
    godot
    blender
  ];

  profiles = {
    zsh.enable = true;
    ssh.enable = true;
    git.enable = true;
    hyprland.enable = true;
    neovim.enable = true;
    firefox.enable = true;
    gaming.enable = true;
    discord.enable = true;
    obs.enable = true;
    virtualization.enable = true;
    zed.enable = true;
  };
}
