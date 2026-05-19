{
  lib,
  ...
}@args:
(lib.mkFeature "grub" {
  options = { };

  configs =
    { ... }:
    {
      boot.loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
        timeout = 5;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true;
          default = "saved";
          efiInstallAsRemovable = true;
          configurationLimit = 8;
          extraEntries = ''
            menuentry "UEFI Firmware Settings" {
              fwsetup
            }
          '';
          extraConfig = ''
            set recordfail_timeout=5
          '';
        };
      };
    };
})
  args
