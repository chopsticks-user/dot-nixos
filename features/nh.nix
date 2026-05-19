{
  lib,
  constants,
  ...
}@args:
(lib.mkFeature "nh" {
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
        NH_FLAKE = constants.directories.nixos;
        NH_OS_FLAKE = constants.directories.nixos;
        NH_HOME_FLAKE = constants.directories.nixos;
        NH_SHOW_ACTIVATION_LOGS = "true";
      };
    };
})
  args
