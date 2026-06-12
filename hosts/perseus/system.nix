{ ... }:
{
  features = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
    core = {
      wifi.home.priority = 101;
    };
  };
}
