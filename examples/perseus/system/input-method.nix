# Japanese, Chinese and Vietnamese input on top of modules.fcitx, through the native options
{ pkgs, ... }:
{
  i18n.inputMethod.fcitx5 = {
    addons = with pkgs; [
      fcitx5-mozc
      fcitx5-rime
      qt6Packages.fcitx5-unikey
    ];
    settings.inputMethod = {
      "Groups/0/Items/1".Name = "mozc";
      "Groups/0/Items/2".Name = "rime";
      "Groups/0/Items/3".Name = "unikey";
    };
  };
}
