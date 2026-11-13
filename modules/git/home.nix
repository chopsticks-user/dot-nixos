{
  lib,
  config,
  fields,
  ...
}:
{
  options = {
    user = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Author name";
            };
            email = lib.mkOption {
              type = lib.types.str;
              description = "Author email";
            };
          };
        }
      );
      default = null;
      description = "Identity written in plain text into the git config";
    };
    identityFromSecrets = lib.mkEnableOption "reading the identity from git/name and git/email in the user's secrets.yaml, so it stays out of the repository";
  };

  configs = lib.mkMerge [
    {
      programs = {
        git = {
          enable = true;
          settings = lib.mkMerge [
            {
              init.defaultBranch = "main";
              pull.rebase = false;
            }
            (lib.mkIf (fields.user != null) {
              inherit (fields) user;
            })
          ];
        };

        gh = {
          enable = true;
          settings = { };
        };
      };
    }
    (lib.mkIf fields.identityFromSecrets {
      sops = {
        secrets = {
          "git/name" = { };
          "git/email" = { };
        };
        templates."gitconfig".content = ''
          [user]
            name = ${config.sops.placeholder."git/name"}
            email = ${config.sops.placeholder."git/email"}
        '';
      };
      programs.git.includes = [ { path = config.sops.templates."gitconfig".path; } ];
    })
  ];
}
