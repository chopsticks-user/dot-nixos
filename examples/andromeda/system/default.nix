# machine identity; everything else is split by concern
{
  imports = [
    ./modules.nix
  ];

  networking.hostName = "andromeda";
  time.timeZone = "America/New_York";
  system.stateVersion = "26.11";
}
