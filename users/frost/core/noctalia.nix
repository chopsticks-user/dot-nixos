{pkgs, ...}: {
  home.packages = with pkgs; [noctalia-shell];

  xdg.configFile."noctalia/settings.json".source = ./noctalia.json;
}
