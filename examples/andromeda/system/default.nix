{ lib, ... }:
{
  networking.hostName = "andromeda";
  system.stateVersion = "26.11";

  nixpkgs.overlays = [
    (lib.mkOverlay "unreal-engine" { })
    (lib.mkOverlay "bottles" { removeWarningPopup = true; })
  ];

  modules = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
  };
}
