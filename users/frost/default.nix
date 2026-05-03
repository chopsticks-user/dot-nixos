{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfreePackages = [
    "rider"
    "clion"
    "claude-code"
    "unreal-engine"
    "unreal-engine-run"
  ];

  home.packages = with pkgs;
    [
      cloc
      tree

      jetbrains.rider
      jetbrains.clion
      godot
      blender
      unreal-engine
      unreal-engine.run
      unreal-engine.run-free
    ]
    ++ [
      inputs.nix-alien.packages.${stdenv.hostPlatform.system}.nix-alien
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
    claude.enable = true;
    distrobox.enable = true;
    zed.enable = true;
  };
}
