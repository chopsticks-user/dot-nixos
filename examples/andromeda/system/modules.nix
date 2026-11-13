# machine-only modules; modules users enable in home.nix turn on their system half automatically
{
  modules = {
    cli.enable = true;
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
  };
}
