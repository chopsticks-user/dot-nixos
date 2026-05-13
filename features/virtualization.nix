{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.virtualization = {
    enable = lib.mkEnableOption "virtualization";
  };

  config =
    let
      cfg = config.features.virtualization;
    in
    lib.mkIf cfg.enable {
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
}
