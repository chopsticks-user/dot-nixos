{config, ...}: {
  imports = [./generated.nix];

  nixpkgs.config.allowUnfree = true;

  hardware = {
    graphics.enable = true;
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    NVD_BACKEND = "direct";
  };

  services.xserver.videoDrivers = ["modesetting" "nvidia"];
}
