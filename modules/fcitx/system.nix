{
  pkgs,
  ...
}:
{
  options = { };

  # add input methods with native i18n.inputMethod.fcitx5.addons and settings, see the examples
  configs = {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        ignoreUserConfig = true;
        addons = [ pkgs.fcitx5-gtk ];
        settings.inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
        };
      };
    };
  };
}
