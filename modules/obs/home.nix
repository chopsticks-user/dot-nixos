{
  lib,
  config,
  pkgs,
  fields,
  ...
}:
{
  options = {
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "OBS plugin packages";
    };
    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          global = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "INI sections written to `obs-studio/global.ini` on every activation";
          };
          user = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "INI sections written to `obs-studio/user.ini` on every activation";
          };
        };
      };
      default = { };
      description = "OBS settings files; changes made in OBS are overwritten on the next activation";
    };
    profiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {
        Untitled = { };
      };
      description = "Profiles by name, each written to its `basic.ini`; recordings go to `user.directories.screencasts`";
    };
  };

  configs = {
    programs.obs-studio = {
      enable = true;
      plugins = fields.plugins;
    };
    home.activation.obsStudioConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      install -Dm644 ${pkgs.writeText "global.ini" (lib.generators.toINI { } fields.settings.global)} \
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
                  SimpleOutput.FilePath = "${config.user.directories.screencasts}";
                  AdvOut.RecFilePath = "${config.user.directories.screencasts}";
                } value
              )
            )
          } ${config.xdg.configHome}/obs-studio/basic/profiles/${name}/basic.ini"
        ) fields.profiles
      )}
    '';
  };
}
