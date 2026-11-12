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
    hello # patched by patches/hello, prints "Hello from perseus!"
  ];
}
