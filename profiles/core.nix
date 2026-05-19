{
  lib,
  config,
  constants,
  pkgs,
  ...
}@args:
(lib.mkProfile "core" {
  options = { };

  configs =
    { ... }:
    {
      home = {
        stateVersion = constants.version;
        inherit (constants) username homeDirectory;
        packages = with pkgs; [
          nerd-fonts.fira-code
          fira
          noto-fonts-color-emoji
        ];
      };

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "FiraCode Nerd Font Mono" ];
          sansSerif = [ "Fira Sans" ];
          serif = [ "Fira Sans" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      xdg =
        (lib.mapAttrNames (name: name + "Home") (
          lib.getAttrs [
            "cache"
            "config"
            "data"
            "state"
            "bin"
          ] constants.directories.home
        ))
        // {
          enable = true;
          userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = true;
            inherit (constants.directories.home)
              desktop
              templates
              publicShare
              documents
              download
              projects
              pictures
              music
              videos
              ;
            extraConfig = lib.mapAttrNames lib.toUpper (
              lib.getAttrs [
                "boxes"
                "media"
                "wallpapers"
                "screenshots"
                "screencasts"
              ] constants.directories.home
            );
          };
        };

      programs = {
        zoxide = {
          enable = true;
          enableZshIntegration = true;
          options = [ "--cmd cd" ];
        };
        fzf = {
          enable = true;
          enableZshIntegration = true;
        };
      };

      sops = {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSopsFile = ../secrets/users/${constants.username}.yaml;
      };
    };
})
  args
