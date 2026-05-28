{ lib, constants, ... }:
{
  xdg =
    (lib.mapAttrNames (name: name + "Home") (
      lib.getAttrs [
        "cache"
        "config"
        "data"
        "state"
        "bin"
      ] constants.directories.home
    ))
    // {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
        inherit (constants.directories.home)
          desktop
          templates
          publicShare
          documents
          download
          projects
          pictures
          music
          videos
          ;
        extraConfig = lib.mapAttrNames lib.toUpper (
          lib.getAttrs [
            "boxes"
            "media"
            "wallpapers"
            "screenshots"
            "screencasts"
          ] constants.directories.home
        );
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
}
