{
  pkgs,
  config,
  constants,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./noctalia.nix
    ./shell.nix
    ./git.nix
    ./browser.nix
    ./themes.nix
    ./editor.nix
    ./terminal.nix
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
      nerd-fonts.fira-code
      fira
      noto-fonts-color-emoji
    ];
    stateVersion = "26.05";
    username = constants.username;
    homeDirectory = constants.home-dir;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["FiraCode Nerd Font Mono"];
      sansSerif = ["Fira Sans"];
      serif = ["Fira Sans"];
      emoji = ["Noto Color Emoji"];
    };
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
