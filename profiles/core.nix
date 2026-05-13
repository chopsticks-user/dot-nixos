{
  config,
  constants,
  pkgs,
  utils,
  ...
}@args:
(utils.mkProfile "core" {
  options = { };

  configs =
    { ... }:
    {
      home = {
        stateVersion = "26.05";
        inherit (constants) username;
        homeDirectory = constants.homeDirectory;
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
          homeDir = config.home.homeDirectory;
          dataHomeDir = "${homeDir}/.local/share";
        in
        {
          enable = true;
          dataHome = dataHomeDir;
          userDirs =
            let
              mediaHomeDir = "${homeDir}/media";
              ignoreHomeDir = "${dataHomeDir}/.xdg-ignore";
            in
            {
              enable = true;
              createDirectories = true;
              setSessionVariables = true;
              desktop = "${ignoreHomeDir}";
              templates = "${ignoreHomeDir}";
              publicShare = "${ignoreHomeDir}";
              documents = "${homeDir}/documents";
              download = "${homeDir}/downloads";
              projects = "${homeDir}/projects";
              pictures = "${mediaHomeDir}/images";
              music = "${mediaHomeDir}/audio";
              videos = "${mediaHomeDir}/videos";
              extraConfig = {
                BOXES = "${homeDir}/boxes";
                MEDIA = "${mediaHomeDir}";
                WALLPAPERS = "${mediaHomeDir}/images/wallpapers";
                SCREENSHOTS = "${mediaHomeDir}/images/screenshots";
                SCREENCASTS = "${mediaHomeDir}/videos/screencasts";
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
    };
})
  args
