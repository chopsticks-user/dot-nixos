# machine identity; everything else is split by concern
{
  imports = [
    ./modules.nix
  ];

  networking.hostName = "andromeda";
  system.stateVersion = "26.11";
}
