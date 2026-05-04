{config, ...}: {
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      desktop = "${config.home.homeDirectory}/.xdg-ignore";
      templates = "${config.home.homeDirectory}/.xdg-ignore";
      publicShare = "${config.home.homeDirectory}/.xdg-ignore";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      projects = "${config.home.homeDirectory}/projects";
      pictures = "${config.home.homeDirectory}/media/images";
      music = "${config.home.homeDirectory}/media/audio";
      videos = "${config.home.homeDirectory}/media/videos";
      extraConfig = {
        BOXES = "${config.home.homeDirectory}/boxes";
        MEDIA = "${config.home.homeDirectory}/media";
        WALLPAPERS = "${config.home.homeDirectory}/media/images/wallpapers";
        SCREENSHOTS = "${config.home.homeDirectory}/media/images/screenshots";
        SCREENCASTS = "${config.home.homeDirectory}/media/videos/screencasts";
      };
    };
  };
}
