{
  pkgs,
  constants,
  ...
}: {
  system.stateVersion = "26.05";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = constants.hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    lshw
    fastfetch
    nvitop
    glances
    wget
    wev
  ];

  features.fcitx.enable = true;
  features.hyprland.enable = true;
  features.nh.enable = true;
  features.ssh.enable = true;
}
