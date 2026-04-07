{ config, self, constants, ... }: {
  home.stateVersion = "26.05";
  home.username = "frost";
  home.homeDirectory = "/home/frost";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/.xdg-ignore";
    templates = "${config.home.homeDirectory}/.xdg-ignore";
    publicShare = "${config.home.homeDirectory}/.xdg-ignore";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
    pictures = "${config.home.homeDirectory}/media/images";
    music = "${config.home.homeDirectory}/media/audio";
    videos = "${config.home.homeDirectory}/media/videos";
    extraConfig = {
      XDG_MEDIA_DIR = "${config.home.homeDirectory}/media";
      XDG_DEV_DIR = "${config.home.homeDirectory}/dev";
      XDG_WALLPAPERS_DIR = "${config.home.homeDirectory}/media/images/wallpapers";
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/media/images/screenshots";
      XDG_SCREENCASTS_DIR = "${config.home.homeDirectory}/media/videos/screencasts";
    };
  };
}
