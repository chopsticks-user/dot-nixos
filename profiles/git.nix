{
  lib,
  config,
  ...
}: let
  cfg = config.profiles.git;
in {
  options.profiles.git = {
    enable = lib.mkEnableOption "git";
    user = {
      name = lib.mkOption {
        type = lib.types.str;
      };
      email = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        settings = {
          inherit (cfg) user;
          init.defaultBranch = "main";
          pull.rebase = false;
        };
      };

      gh = {
        enable = true;
        settings = {};
      };
    };
  };
}
