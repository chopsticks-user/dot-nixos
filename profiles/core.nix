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
          mkHomePath = path: "${config.home.homeDirectory}/${path}";
          ignoreHomePath = "${mkHomePath constants.directories.home.data}/.xdg-ignore";
        in
        {
          enable = true;
          cacheHome = mkHomePath constants.directories.home.cache;
          configHome = mkHomePath constants.directories.home.config;
          dataHome = mkHomePath constants.directories.home.data;
          stateHome = mkHomePath constants.directories.home.state;
          binHome = mkHomePath constants.directories.home.bin;
          userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = true;
            desktop = ignoreHomePath;
            templates = ignoreHomePath;
            publicShare = ignoreHomePath;
            documents = mkHomePath "documents";
            download = mkHomePath "downloads";
            projects = mkHomePath "projects";
            pictures = mkHomePath "media/images";
            music = mkHomePath "media/audio";
            videos = mkHomePath "media/videos";
            extraConfig = {
              BOXES = mkHomePath "boxes";
              MEDIA = mkHomePath "media";
              WALLPAPERS = mkHomePath "media/images/wallpapers";
              SCREENSHOTS = mkHomePath "media/images/screenshots";
              SCREENCASTS = mkHomePath "media/videos/screencasts";
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
