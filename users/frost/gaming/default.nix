{...}: {
  imports = [
    ./steam.nix
    ./gamemode.nix
    ./mangohud.nix
  ];

  # steam launch options: gamemoderun gamescope -f -e -- mangohud %command%
}
