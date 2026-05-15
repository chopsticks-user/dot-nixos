{ config, ... }:
{
  sops = {
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
  };
}
