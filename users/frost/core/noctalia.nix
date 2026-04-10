{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [noctalia-shell];

  home.activation.noctalia-settings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ~/.config/noctalia
    cp ${./noctalia.json} ~/.config/noctalia/settings.json
  '';
}
