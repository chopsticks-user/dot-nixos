{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.features.docs = {
    enable = lib.mkEnableOption "docs";
  };

  config =
    let
      cfg = config.features.docs;
    in
    lib.mkIf cfg.enable {
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
