# machine identity; everything else is split by concern
{
  imports = [
    ./modules.nix
    ./packages.nix
    ./seanime.nix
  ];

  networking.hostName = "perseus";
  time.timeZone = "America/New_York";
  system.stateVersion = "26.11";
}
