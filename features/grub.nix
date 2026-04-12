{
  config,
  lib,
  ...
}: let
  cfg = config.features.grub;
in {
  options.features.grub = {
    enable = lib.mkEnableOption "grub";
  };

  config = lib.mkIf cfg.enable {
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
}
