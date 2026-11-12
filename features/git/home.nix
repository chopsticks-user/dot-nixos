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
            };
            email = lib.mkOption {
              type = lib.types.str;
            };
          };
        }
      );
      default = null;
    };
    include = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.path;
              description = "Path to a gitconfig file to include.";
            };
            condition = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Optional condition for the include (e.g. "gitdir:~/work/").
                If null, the include is unconditional.
              '';
            };
          };
        }
      );
      default = [ ];
    };
  };

  configs = {
    sops = {
      secrets = {
        "git/name" = { };
        "git/email" = { };
      };

      templates = {
        "gitconfig" = {
          content = ''
            [user]
              name = ${config.sops.placeholder."git/name"}
              email = ${config.sops.placeholder."git/email"}
          '';
        };
      };
    };

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
        includes = [ { path = config.sops.templates."gitconfig".path; } ];
      };

      gh = {
        enable = true;
        settings = { };
      };
    };
  };
}
