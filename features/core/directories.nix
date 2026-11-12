{ lib, config, ... }:
{
  xdg =
    (lib.mapAttrNames (name: name + "Home") (
      lib.getAttrs [
        "cache"
        "config"
        "data"
        "state"
        "bin"
      ] config.user.directories
    ))
    // {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
        inherit (config.user.directories)
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
          ] config.user.directories
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
