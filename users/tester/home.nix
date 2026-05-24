{ config, ... }:
{
  sops = {
    secrets = {
      "git/name" = { };
      "git/email" = { };
    };

    templates = {
      "gitconfig" = {
        content = ''
          [user]
            name = ${config.sops.placeholder."git/name"}
            email = ${config.sops.placeholder."git/email"}
        '';
      };
    };
  };

  profiles = {
    zsh.enable = true;
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
    zed.enable = true;
  };
}
