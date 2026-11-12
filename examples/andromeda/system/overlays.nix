# overlays from dot-nixos overlays/, shared by the system and every user
{ lib, ... }:
{
  nixpkgs.overlays = [
    (lib.mkOverlay "unreal-engine" { })
    (lib.mkOverlay "bottles" { removeWarningPopup = true; })
  ];
}
