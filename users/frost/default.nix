{
  pkgs,
  inputs,
  constants,
  ...
}: {
  imports = [
    ./overlays
  ];

  nixpkgs.config.allowUnfreePackages = [
    "rider"
    "clion"
  ];

  home.packages = with pkgs;
    [
      cloc
      tree

      jetbrains.rider
      jetbrains.clion
      godot
      blender
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
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  home.file = let
    mkClionEntry = {
      name,
      dir,
    }: {
      ".local/share/applications/clion-${name}.desktop".text = ''
        [Desktop Entry]
        Name=CLion (${name})
        Exec=nix develop ${dir} --command clion ${dir}
        Icon=clion
        Type=Application
        Categories=Development;IDE;
      '';
    };
    projects = [
      {
        name = "andromeda";
        dir = "${constants.home-dir}/dev/andromeda";
      }
    ];
  in
    builtins.foldl' (acc: p: acc // mkClionEntry p) {} projects;
}
