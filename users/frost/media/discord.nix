{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
    ];

  programs.discord = {
    enable = true;
    settings = {
      SKIP_HOST_UPDATE = true;
    };
  };
}
