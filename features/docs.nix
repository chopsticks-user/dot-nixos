{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.docs;
in {
  options.features.docs = {
    enable = lib.mkEnableOption "docs";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wikiman
      tldr
    ];

    documentation = {
      enable = true;
      man = {
        enable = true;
        cache = {
          enable = true;
          generateAtRuntime = true;
        };
      };
      dev.enable = true;
      doc.enable = true;
      info.enable = true;
    };
  };
}
