{ pkgs, ... }:
{
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
