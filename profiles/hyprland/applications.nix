{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfreePackages = [
    "harmonoid"
  ];

  profiles.open = with pkgs; {
    enable = true;
    html = firefox;
    image = {
      package = kdePackages.gwenview;
      desktopEntry = "org.kde.gwenview";
    };
    pdf = {
      package = kdePackages.okular;
      desktopEntry = "org.kde.okular";
    };
    video = {
      package = haruna;
      desktopEntry = "org.kde.haruna";
    };
    audio = {
      package = harmonoid;
      desktopEntry = "org.kde.harmonoid";
    };
    directory = {
      package = kdePackages.dolphin;
      desktopEntry = "org.kde.dolphin";
    };
  };
}
