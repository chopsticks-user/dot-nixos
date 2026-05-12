{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.qemu = {
    enable = lib.mkEnableOption "qemu";
  };

  config =
    let
      cfg = config.features.qemu;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        qemu
        quickemu
      ];

      systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "riscv64-linux"
      ];
    };
}
