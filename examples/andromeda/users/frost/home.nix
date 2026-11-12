{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfreePackages = [
    "obsidian"
    "spotify"
    "claude-code"
    "discord"
    "discord-unwrapped"
  ];

  home.packages = with pkgs; [
    godot
    blender
    gimp-with-plugins
    krita
    obsidian
    hyprmod
    spotify
    discord
  ];

  features = {
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
    vscode.enable = true;
    llm.enable = true;
  };
}
