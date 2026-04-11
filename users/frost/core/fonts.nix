{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    fira
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["FiraCode Nerd Font Mono"];
      sansSerif = ["Fira Sans"];
      serif = ["Fira Sans"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
