{
  lib,
  constants,
  ...
}@args:
(lib.utils.mkFeature "nh" {
  options = { };

  configs =
    { ... }:
    {
      programs.nh = {
        enable = true;
        clean.enable = lib.mkDefault true;
        clean.extraArgs = lib.mkDefault "--keep-since 7d --keep 8";
      };

      environment.sessionVariables = {
        NH_FLAKE = constants.configPath;
        NH_OS_FLAKE = constants.configPath;
        NH_HOME_FLAKE = constants.configPath;
        NH_SHOW_ACTIVATION_LOGS = "true";
      };
    };
})
  args
