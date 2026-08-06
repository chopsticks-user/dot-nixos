{ pkgs,... }:
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

  nixpkgs.config.allowUnfreePackages = [
    "steamcmd"
  ];

  environment.systemPackages = with pkgs; [
    seanime
    steamcmd
  ];
}
