{
  lib,
  config,
  ...
}: let
  cfg = config.profiles.distrobox;
in {
  options.profiles.distrobox = {
    enable = lib.mkEnableOption "distrobox";
  };

  config = lib.mkIf cfg.enable {
    programs.distrobox = {
      enable = true;
      enableSystemdUnit = true;
      settings = {
        container_manager = "podman";
        container_always_pull = "1";
        container_additional_volumes = "/nix/store:/nix/store:ro";
      };
      # run distrobox assemble create --file ~/.config/distrobox/containers.ini --verbose 2>&1
      # if containers don't exist
      containers = {
        arch = {
          image = "archlinux:latest";
          init = false;
        };
      };
    };
  };
}
