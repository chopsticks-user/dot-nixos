{pkgs, ...}: {
  home.packages = with pkgs; [
    steam
    steam-run
    protontricks
  ];

  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];
}
