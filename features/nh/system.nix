{
  lib,
  config,
  ...
}:
{
  options = { };

  configs = {
    programs.nh = {
      enable = true;
      clean.enable = lib.mkDefault true;
      clean.extraArgs = lib.mkDefault "--keep-since 7d --keep 8";
    };

    environment.sessionVariables = {
      NH_FLAKE = config.machine.directories.nixos;
      NH_OS_FLAKE = config.machine.directories.nixos;
      NH_SHOW_ACTIVATION_LOGS = "true";
    };
  };
}
