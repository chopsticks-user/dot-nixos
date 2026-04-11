{
  lib,
  config,
  pkgs,
  constants,
  ...
}: {
  home = {
    packages = with pkgs; [noctalia-shell];
    activation.noctaliaConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${config.xdg.configHome}/noctalia"
      ln -sf "${constants.config-path}/users/frost/core/noctalia.json" \
             "${config.xdg.configHome}/noctalia/settings.json"
    '';
  };
}
