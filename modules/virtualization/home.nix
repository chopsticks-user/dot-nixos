{
  pkgs,
  config,
  ...
}:
{
  options = { };

  configs = {
    home.packages = with pkgs; [
      qemu
      quickemu
      virt-manager
    ];

    programs.distrobox = {
      enable = true;
      enableSystemdUnit = true;
      settings = {
        container_manager = "podman";
        container_always_pull = "1";
        container_additional_volumes = "/nix/store:/nix/store:ro";
        container_home_prefix = "${config.home.homeDirectory}/boxes";
        skip_workdir = "1";
      };
    };

    xdg.configFile."containers/storage.conf".text = ''
      [storage]
      driver = "overlay"
      rootless_storage_path = "${config.home.homeDirectory}/boxes/.podman-storage"
    '';
  };
}
