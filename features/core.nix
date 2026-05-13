{
  config,
  lib,
  pkgs,
  inputs,
  constants,
  ...
}:
{
  options.features.core = {
    enable = lib.mkEnableOption "core";
    kernel = lib.mkOption {
      type = lib.types.enum [
        "testing"
        "latest"
      ];
      default = "latest";
      description = "Kernel version to use";
    };
    state-version = lib.mkOption {
      type = lib.types.str;
      default = config.system.nixos.release;
      description = "State version";
    };
    gpu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "nvidia"
          "amd"
          "intel"
        ]
      );
      default = null;
      description = "GPU type";
    };
  };

  config =
    let
      cfg = config.features.core;
    in
    lib.mkIf cfg.enable {
      system.stateVersion = cfg.state-version;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        cores = 0;
        max-jobs = "auto";
      };

      boot.kernelPackages = pkgs."linuxPackages_${cfg.kernel}";

      environment.systemPackages =
        let
          inherit (inputs.nix-alien.packages.${constants.system.current}) nix-alien;
          btop =
            if cfg.gpu == "nvidia" then
              pkgs.btop-cuda
            else if cfg.gpu == "amd" then
              pkgs.btop-rocm
            else
              pkgs.btop;
        in
        with pkgs;
        [
          # core & nix tooling
          home-manager
          nix-alien
          nixd
          nixfmt
          coreutils

          # system administration & monitoring
          efibootmgr
          psmisc
          lshw
          inotify-tools
          lazyjournal
          fastfetch
          ncdu
          btop

          # CLI wizardy kit, coreutils already includes sort, uniq, cut
          ripgrep
          sd
          fd
          jq
          yq
          gawk
          findutils # xargs
          gnused

          # files & directories
          git
          tree
          cloc
          curl
          wget
          zip
          unzip
          pkg-config
          patchelf
          file

          # miscellaneous
          wl-clipboard
          wev
        ];

      programs = {
        nix-index-database.comma.enable = true;
        nix-index.enable = true;
        command-not-found.enable = false;
      };
    };
}
