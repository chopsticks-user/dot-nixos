{ config, pkgs, self, ... }: {
  imports = [
    ./home.nix
    ./hyprland.nix
    ./noctalia.nix
    ./bash.nix
    ./git.nix
    ./firefox.nix
    ./themes.nix
    ./neovim.nix
    ./kitty.nix
    ./lf.nix
    ./ssh.nix
  ];
}
