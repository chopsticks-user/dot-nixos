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
          mkPathBuilder = kind: name: "${config.home.homeDirectory}/${constants.directories.${kind}.${name}}";
          mkUserPath = name: (mkPathBuilder "user") name;
          mkHomePath = name: (mkPathBuilder "home") name;
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
            desktop = mkUserPath "desktop";
            templates = mkUserPath "templates";
            publicShare = mkUserPath "publicShare";
            documents = mkUserPath "documents";
            download = mkUserPath "downloads";
            projects = mkUserPath "projects";
            pictures = mkUserPath "pictures";
            music = mkUserPath "music";
            videos = mkUserPath "videos";
            extraConfig = {
              BOXES = mkUserPath "boxes";
              MEDIA = mkUserPath "media";
              WALLPAPERS = mkUserPath "wallpapers";
              SCREENSHOTS = mkUserPath "screenshots";
              SCREENCASTS = mkUserPath "screencasts";
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
