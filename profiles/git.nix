{
  lib,
  utils,
  ...
}@args:
(utils.mkProfile "git" {
  options = {
    user = {
      name = lib.mkOption {
        type = lib.types.str;
      };
      email = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  configs =
    { fields, ... }:
    {
      programs = {
        git = {
          enable = true;
          settings = {
            inherit (fields) user;
            init.defaultBranch = "main";
            pull.rebase = false;
          };
        };

        gh = {
          enable = true;
          settings = { };
        };
      };
    };
})
  args
