{ constants, ... }:
{
  features = {
    core = {
      enable = true;
      kernel = "testing";
      state-version = "26.05";
      gpu = "nvidia";
    };
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
    ssh.enable = true;
    virtualization.enable = true;
  };

  networking = {
    hostName = constants.hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";
}
