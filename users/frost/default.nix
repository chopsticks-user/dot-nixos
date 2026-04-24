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
    "claude-code"
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

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };

  programs.distrobox = {
    enable = true;
    enableSystemdUnit = true;

    settings = {
      container_manager = "podman";
      container_always_pull = "1";
      container_additional_volumes = "/nix/store:/nix/store:ro";
    };

    # run distrobox assemble create --file ~/.config/distrobox/containers.ini --verbose 2>&1
    # if containers don't exist
    containers = {
      arch = {
        image = "archlinux:latest";
        init = false;
      };
    };
  };
}
