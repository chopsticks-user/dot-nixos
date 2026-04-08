{
  pkgs,
  constants,
  ...
}: {
  system.stateVersion = "26.05";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = constants.hostname;
    networkmanager.enable = true;
  };

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

  features = {
    fcitx.enable = true;
    hyprland.enable = true;
    nh.enable = true;
    ssh.enable = true;
  };
}
