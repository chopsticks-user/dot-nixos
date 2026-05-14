{ pkgs, config, ... }:
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
  ];

  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/users/frost.yaml;

    secrets."git/name" = { };
    secrets."git/email" = { };

    templates."gitconfig" = {
      content = ''
        [user]
            name = ${config.sops.placeholder."git/name"}
            email = ${config.sops.placeholder."git/email"}
      '';
    };
  };

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
      include = [
        { path = config.sops.templates."gitconfig".path; }
      ];
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

  programs.git = {
    enable = true;
    includes = [
      { path = config.sops.templates."gitconfig".path; }
    ];
  };
}
