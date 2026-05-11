{
  lib,
  config,
  ...
}:
{
  options.features.distrobox = {
    enable = lib.mkEnableOption "distrobox";
  };

  config =
    let
      cfg = config.features.distrobox;
    in
    lib.mkIf cfg.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };
    };
}
