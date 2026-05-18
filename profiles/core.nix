{
  lib,
  config,
  constants,
  pkgs,
  ...
}@args:
(lib.utils.mkProfile "core" {
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
        let
          mkHomePath = name: "${config.home.homeDirectory}/${constants.directories.home.${name}}";
        in
        {
          enable = true;
          cacheHome = mkHomePath "cache";
          configHome = mkHomePath "config";
          dataHome = mkHomePath "data";
          stateHome = mkHomePath "state";
          binHome = mkHomePath "bin";
          userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = true;
            desktop = mkHomePath "desktop";
            templates = mkHomePath "templates";
            publicShare = mkHomePath "publicShare";
            documents = mkHomePath "documents";
            download = mkHomePath "downloads";
            projects = mkHomePath "projects";
            pictures = mkHomePath "pictures";
            music = mkHomePath "music";
            videos = mkHomePath "videos";
            extraConfig = {
              BOXES = mkHomePath "boxes";
              MEDIA = mkHomePath "media";
              WALLPAPERS = mkHomePath "wallpapers";
              SCREENSHOTS = mkHomePath "screenshots";
              SCREENCASTS = mkHomePath "screencasts";
            };
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
