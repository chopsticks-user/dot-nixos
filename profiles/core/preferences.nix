{ pkgs, constants, ... }:
let
  dark = constants.theme == "dark";
  gtkTheme = if dark then "Adwaita-dark" else "Adwaita";
  gtkEnvTheme = if dark then "Adwaita:dark" else "Adwaita";
in
{
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    fira
    noto-fonts-color-emoji
  ];

  home.pointerCursor = {
    enable = true;
    x11.enable = true;
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.mochaPink;
    name = "catppuccin-mocha-pink-cursors";
    size = 24;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FiraCode Nerd Font Mono" ];
      sansSerif = [ "Fira Sans" ];
      serif = [ "Fira Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = if dark then "prefer-dark" else "prefer-light";
    };
  };
  gtk = {
    enable = true;
    gtk4.theme = {
      name = gtkTheme;
      package = pkgs.gnome-themes-extra;
    };
    theme = {
      name = gtkTheme;
      package = pkgs.gnome-themes-extra;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };
  home.sessionVariables = {
    THEME = "${constants.theme}";
    GTK_THEME = gtkEnvTheme;
  };
}
