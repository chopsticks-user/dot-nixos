{ ... }:
{
  features = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
    core = {
      wifi = [
        {
          name = "home";
          priority = 99;
        }
      ];
    };
  };
}
