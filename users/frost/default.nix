{ pkgs, constants, ... }:
{
  nixpkgs.config.allowUnfreePackages = [
    "rider"
    "clion"
    "claude-code"
  ];

  home.packages = with pkgs; [
    jetbrains.rider
    jetbrains.clion
    godot
    blender
    doppler
  ];

  profiles = {
    core.enable = true;
    zsh = {
      enable = true;
      shellAliases = {
      };
    };
    ssh.enable = true;
    git = {
      enable = true;
      inherit (constants.profiles.git) user;
    };
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
