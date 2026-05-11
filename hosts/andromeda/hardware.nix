{
  config,
  inputs,
  ...
}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-gpu-nvidia-nonprime
    common-pc-ssd
    common-pc
    ./generated.nix
  ];

  nixpkgs.config.allowUnfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia-container-toolkit.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      powerManagement.enable = true;
      videoAcceleration = true;
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

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];
}
