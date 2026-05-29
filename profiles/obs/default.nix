{
  lib,
  config,
  pkgs,
  fields,
  constants,
  ...
}:
{
  options = {
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          global = lib.mkOption {
            type = lib.types.attrs;
            default = { };
          };
          user = lib.mkOption {
            type = lib.types.attrs;
            default = { };
          };
        };
      };
      default = { };
    };
    profiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {
        Untitled = { };
      };
    };
  };

  configs = {
    programs.obs-studio = {
      enable = true;
      plugins = fields.plugins;
    };
    home.activation.obsStudioConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      install -Dm644 ${pkgs.writeText "global.ini" (lib.generators.toINI { } fields.settings.user)} \
        ${config.xdg.configHome}/obs-studio/global.ini

      install -Dm644 ${pkgs.writeText "user.ini" (lib.generators.toINI { } fields.settings.user)} \
        ${config.xdg.configHome}/obs-studio/user.ini

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: value:
          "install -Dm644 ${
            pkgs.writeText "${name}-basic.ini" (
              lib.generators.toINI { } (
                lib.recursiveUpdate {
                  General = (value.General or { }) // {
                    Name = name;
                  };
                  SimpleOutput.FilePath = "${constants.directories.home.screencasts}";
                  AdvOut.RecFilePath = "${constants.directories.home.screencasts}";
                } value
              )
            )
          } ${config.xdg.configHome}/obs-studio/basic/profiles/${name}/basic.ini"
        ) fields.profiles
      )}
    '';
  };
}
