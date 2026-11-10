{
  pkgs,
  constants,
  ...
}:
{
  nixpkgs.config.allowUnfreePackages = [
    "rider"
    "clion"
    "obsidian"
    "spotify"
    "claude-code"
    "discord"
    "discord-unwrapped"
  ];

  home.packages = with pkgs; [
    jetbrains.rider
    jetbrains.clion
    godot
    blender
    gimp-with-plugins
    krita
    obsidian
    hyprmod
    spotify
    discord
  ];

  profiles = {
    zsh.enable = true;
    ssh.enable = true;
    git.enable = true;
    hyprland.enable = true;
    neovim.enable = true;
    firefox.enable = true;
    gaming.enable = true;
    obs.enable = true;
    virtualization.enable = true;
    zed.enable = true;
    llm.enable = true;
  };
}
