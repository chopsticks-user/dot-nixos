{
  lib,
  pkgs,
  ...
}@args:
(lib.mkFeature "fcitx" {
  options = { };

  configs =
    { ... }:
    {
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };
        inputMethod = {
          enable = true;
          type = "fcitx5";
          fcitx5 = {
            waylandFrontend = true;
            ignoreUserConfig = true;
            addons = with pkgs; [
              fcitx5-mozc
              fcitx5-rime
              fcitx5-gtk
              qt6Packages.fcitx5-unikey
            ];
            settings = {
              inputMethod = {
                "Groups/0" = {
                  Name = "Default";
                  "Default Layout" = "us";
                  DefaultIM = "keyboard-us";
                };
                "Groups/0/Items/0".Name = "keyboard-us";
                "Groups/0/Items/1".Name = "mozc";
                "Groups/0/Items/2".Name = "rime";
                "Groups/0/Items/3".Name = "unikey";
              };
            };
          };
        };
      };

      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
    };
})
  args
