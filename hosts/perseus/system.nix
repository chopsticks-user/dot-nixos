{
  pkgs,
  constants,
  ...
}: {
  features = {
    core = {
      enable = true;
      kernel = "latest";
      state-version = "26.05";
      gpu = "nvidia";
    };
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    hyprland.enable = true;
    fcitx.enable = true;
    ssh.enable = true;
    qemu.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libgpiod
  ];

  networking = {
    hostName = constants.hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  security.wrappers.btop = {
    owner = "root";
    group = "root";
    capabilities = "cap_perfmon+ep";
    source = "${pkgs.btop}/bin/btop";
  };
}
