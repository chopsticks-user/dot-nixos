{ constants, ... }:
{
  features = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    hyprland.enable = true;
    fcitx.enable = true;
    ssh.enable = true;
  };

  networking = {
    hostName = constants.hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";
}
