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
      XDG_DEV_DIR = "${config.home.homeDirectory}/dev";
      XDG_BOX_DIR = "${config.home.homeDirectory}/boxes";
      XDG_MEDIA_DIR = "${config.home.homeDirectory}/media";
      XDG_WALLPAPERS_DIR = "${config.home.homeDirectory}/media/images/wallpapers";
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/media/images/screenshots";
      XDG_SCREENCASTS_DIR = "${config.home.homeDirectory}/media/videos/screencasts";
    };
  };
}
