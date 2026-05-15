{
  lib,
  pkgs,
  ...
}@args:
(lib.utils.mkFeature "virtualization" {
  options = { };

  configs =
    { ... }:
    {
      hardware.nvidia-container-toolkit.enable = true;

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
})
  args
