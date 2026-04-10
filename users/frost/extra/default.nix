{pkgs, ...}: {
  imports = [];

  home.packages = with pkgs; [
    lolcat
    cowsay
    fortune
  ];
}
