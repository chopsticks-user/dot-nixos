{
  pkgs,
  config,
  ...
}:
{
  options = { };

  configs = {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
      "riscv64-linux"
    ];
  };

  # container homes and rootless podman storage
  persist.home = {
    directories = [ config.machine.directories.home.boxes ];
    files = [ ];
  };
}
