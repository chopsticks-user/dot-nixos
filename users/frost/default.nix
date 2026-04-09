{
  pkgs,
  config,
  constants,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./noctalia.nix
    ./zsh.nix
    ./git.nix
    ./firefox.nix
    ./themes.nix
    ./neovim.nix
    ./kitty.nix
    ./file-manager.nix
    ./ssh.nix
    ./zoxide.nix
    ./dev.nix
    ./obs.nix
    ./rmpc.nix
  ];

  home = {
    packages = with pkgs; [
      lolcat
      cowsay
      fortune
    ];
    stateVersion = "26.05";
    username = constants.username;
    homeDirectory = constants.home-dir;
  };

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
