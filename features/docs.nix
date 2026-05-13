{
  lib,
  pkgs,
  ...
}@args:
(lib.utils.mkFeature "docs" {
  options = { };

  configs = {...}: {
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
})
  args
