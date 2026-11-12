# machine-only modules; modules users enable in home.nix turn on their system half automatically
{
  modules = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
    # ssid and password come from networking/wifi/home/* in secrets.yaml
    core.wifi.home.priority = 101;
  };
}
