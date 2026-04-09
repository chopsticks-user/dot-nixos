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

  documentation = {
    enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lshw
    fastfetch
    glances
    wget
    wev
    psmisc
    wikiman
    tldr
    nvtopPackages.full
  ];

  features = {
    fcitx.enable = true;
    hyprland.enable = true;
    nh.enable = true;
    ssh.enable = true;
  };
}
