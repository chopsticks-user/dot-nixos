{
  lib,
  config,
  ...
}:
let
  dirs = config.user.directories;
in
{
  imports = [ ./user-options.nix ];

  options = { };

  configs = {
    xdg =
      (lib.mapAttrNames (name: name + "Home") (
        lib.getAttrs [
          "cache"
          "config"
          "data"
          "state"
          "bin"
        ] dirs
      ))
      // {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = true;
          inherit (dirs)
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
            ] dirs
          );
        };
      };

    sops.age.sshKeyPaths = [ dirs.identity ];

    home.sessionVariables = {
      SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i ${dirs.identity}";
      SHELL = lib.getExe config.user.shell;
    }
    // lib.optionalAttrs (config.user.terminal != null) {
      TERMINAL = lib.getExe config.user.terminal;
    };
  };
}
