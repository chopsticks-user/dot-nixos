{
  pkgs,
  constants,
  ...
}:
let
  palworld = pkgs.writeShellApplication {
    name = "palworld";
    runtimeInputs = with pkgs; [
      steamcmd
      steam-run
      coreutils
      findutils
      util-linux
      procps
    ];
    runtimeEnv = {
      PALWORLD_SERVER_DIR = "${constants.directories.home.data}/palworld"; # server install + saves
      PALWORLD_DATA_DIR = "${constants.directories.home.projects}/palworld"; # ← your config folder
      PALWORLD_STATE_DIR = "${constants.directories.home.state}/palworld"; # pid file + log
    };
    text = builtins.readFile ./palworld.sh;
  };
in
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
    palworld
    discord
    # claude code plugins need these
    bun
    nodejs_latest
    uv
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

  programs.claude-code = {
    enable = true;
  };
}
