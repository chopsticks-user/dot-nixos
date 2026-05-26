{ pkgs, config, ... }:
{
  nixpkgs.config.allowUnfreePackages = [
    "rider"
    "clion"
  ];

  home.packages = with pkgs; [
    jetbrains.rider
    jetbrains.clion
    godot
    blender
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
    mime = with pkgs; {
      enable = true;
      html = firefox;
      image = imv;
      pdf = {
        package = zathura;
        desktopEntry = "org.pwmt.zathura";
      };
      directory = {
        package = superfile;
        desktopEntry = {
          name = "Superfile";
          comment = "Terminal file manager";
          exec = "${pkgs.writeShellScriptBin "superfile-open" ''
            ''$TERMINAL ${pkgs.superfile}/bin/superfile "$@"
          ''}/bin/superfile-open %u";
          terminal = false;
        };
      };
    };
  };
}
