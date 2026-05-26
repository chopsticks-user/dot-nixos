{
  constants,
  pkgs,
  ...
}:
let
  dark = constants.theme == "dark";
  gtkTheme = if dark then "Adwaita-dark" else "Adwaita";
  gtkEnvTheme = if dark then "Adwaita:dark" else "Adwaita";
in
{
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
    platformTheme.name = "gtk";
  };
  home.sessionVariables = {
    THEME = "${constants.theme}";
    GTK_THEME = gtkEnvTheme;
  };
}
