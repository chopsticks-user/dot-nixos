# virtual hardware, enough for the machine to evaluate as a whole
{
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.loader.systemd-boot.enable = true;
}
