{ pkgs, ... }:
{
  features = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
    core = {
      wifi.home.priority = 101;
    };
  };

  networking.firewall.allowedTCPPorts = [
    43211
  ];

  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
    "steamcmd"
  ];

  environment.systemPackages = with pkgs; [
    seanime
    steamcmd
  ];
}
