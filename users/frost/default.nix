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

    containers = {
      arch = {
        image = "archlinux:latest";
        init = false;
        init_hooks = [
          "pacman -Syu --noconfirm"
          "pacman -S --needed --noconfirm base-devel git"
          "git clone https://aur.archlinux.org/paru.git /tmp/paru"
          "cd /tmp/paru && makepkg -si --noconfirm"
        ];
      };
    };
  };
}
