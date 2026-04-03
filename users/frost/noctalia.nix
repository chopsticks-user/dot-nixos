{ pkgs, ... }: {
  home.packages = with pkgs; [
    noctalia-shell
  ];
  
  xdg.configFile."noctalia-shell/config.json".source = ./noctalia.json;
}
