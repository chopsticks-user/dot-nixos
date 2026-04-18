{
  pkgs,
  constants,
  ...
}: {
  imports = [
    ./overlays
  ];

  nixpkgs.config.allowUnfreePackages = [
    "rider"
  ];

  home.packages = with pkgs; [
    cloc
    tree
    ilspycmd
    jetbrains.rider
    python3
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
      user = {
        name = "chopsticks-user";
        email = "frostyfrost273@gmail.com";
      };
    };

    hyprland.enable = true;

    neovim.enable = true;

    firefox.enable = true;

    gaming.enable = true;

    discord.enable = true;

    obs.enable = true;
  };
}
