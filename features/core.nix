{
  lib,
  config,
  pkgs,
  inputs,
  constants,
  ...
}@args:
(lib.utils.mkFeature "core" {
  options = {
    kernel = lib.mkOption {
      type = lib.types.enum [
        "testing"
        "latest"
      ];
      default = "latest";
      description = "Kernel version to use";
    };
    stateVersion = lib.mkOption {
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

  configs =
    { fields, ... }:
    {
      system.stateVersion = fields.stateVersion;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        cores = 0;
        max-jobs = "auto";
      };

      boot.kernelPackages = pkgs."linuxPackages_${fields.kernel}";

      environment.systemPackages =
        let
          inherit (inputs.nix-alien.packages.${constants.system.current}) nix-alien;
          btop =
            if fields.gpu == "nvidia" then
              pkgs.btop-cuda
            else if fields.gpu == "amd" then
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
})
  args
