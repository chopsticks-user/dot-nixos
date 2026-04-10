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
      cache = {
        enable = true;
        generateAtRuntime = true;
      };
    };
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lshw
    fastfetch
    wget
    wev
    psmisc
    wikiman
    tldr
    btop-cuda
    lazyjournal
    ncdu
    wl-clipboard
    efibootmgr
  ];

  features = {
    fcitx.enable = true;
    hyprland.enable = true;
    nh.enable = true;
    ssh.enable = true;
  };
}
