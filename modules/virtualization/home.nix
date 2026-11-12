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
      #      bottles
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
      # run distrobox assemble create --file ~/.config/distrobox/containers.ini --verbose 2>&1
      # if containers don't exist
      containers = {
        arch = {
          image = "archlinux:latest";
          init = false;
          volume = "${config.home.homeDirectory}/projects:${config.home.homeDirectory}/projects";
          additional_packages = "base-devel git clang cmake ninja rust";
          pre_init_hooks = [
            "export SHELL=/bin/bash"
          ];
          init_hooks = [
            "rm -rf /tmp/paru"
            "cd /tmp && sudo -u ${config.home.username} git clone https://aur.archlinux.org/paru.git"
            "cd /tmp/paru && sudo -u ${config.home.username} makepkg --noconfirm"
            "pacman -U --noconfirm /tmp/paru/paru-*.pkg.tar.zst"
          ];
        };
      };
    };

    xdg.configFile."containers/storage.conf".text = ''
      [storage]
      driver = "overlay"
      rootless_storage_path = "${config.home.homeDirectory}/boxes/.podman-storage"
    '';
  };
}
