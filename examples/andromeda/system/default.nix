# machine identity; everything else is split by concern
{
  imports = [
    ./modules.nix
    ./overlays.nix
  ];

  networking.hostName = "andromeda";
  system.stateVersion = "26.11";
}
