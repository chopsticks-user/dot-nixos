{config, ...}: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    desktop = "${config.home.homeDirectory}/.xdg-ignore";
    templates = "${config.home.homeDirectory}/.xdg-ignore";
    publicShare = "${config.home.homeDirectory}/.xdg-ignore";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
    pictures = "${config.home.homeDirectory}/media/images";
    music = "${config.home.homeDirectory}/media/audio";
    videos = "${config.home.homeDirectory}/media/videos";
    extraConfig = {
      DEV = "${config.home.homeDirectory}/dev";
      BOXES = "${config.home.homeDirectory}/boxes";
      MEDIA = "${config.home.homeDirectory}/media";
      WALLPAPERS = "${config.home.homeDirectory}/media/images/wallpapers";
      SCREENSHOTS = "${config.home.homeDirectory}/media/images/screenshots";
      SCREENCASTS = "${config.home.homeDirectory}/media/videos/screencasts";
    };
  };
}
