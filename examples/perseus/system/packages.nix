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
    hello # patched by overlays/hello, prints "Hello from perseus!"
  ];
}
