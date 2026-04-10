{pkgs, ...}: {
  home.packages = with pkgs; [noctalia-shell];

  home.file.".config/noctalia/settings.json".source = ./noctalia.json;
}
