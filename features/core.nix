{
  config,
  lib,
  pkgs,
  inputs,
  constants,
  ...
}: {
  options.features.core = {
    enable = lib.mkEnableOption "core";
    kernel = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "Kernel version to use";
    };
    state-version = lib.mkOption {
      type = lib.types.str;
      default = config.system.nixos.release;
      description = "State version";
    };
    gpu = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum ["nvidia" "amd" "intel"]);
      default = null;
      description = "GPU type";
    };
  };

  config = let
    cfg = config.features.core;
  in
    lib.mkIf cfg.enable {
      system.stateVersion = cfg.state-version;
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        cores = 0;
        max-jobs = "auto";
      };
      boot.kernelPackages = pkgs."linuxPackages_${cfg.kernel}";

      environment.systemPackages = let
        inherit (inputs.nix-alien.packages.${constants.system.current}) nix-alien;
        btop =
          if cfg.gpu == "nvidia"
          then pkgs.btop-cuda
          else if cfg.gpu == "amd"
          then pkgs.btop-rocm
          else pkgs.btop;
      in
        with pkgs; [
          home-manager
          efibootmgr
          git
          psmisc
          lshw
          fastfetch
          btop
          lazyjournal
          ncdu
          wl-clipboard
          jq
          wget
          wev
          zip
          unzip
          nix-alien
          inotify-tools
          patchelf
          pkg-config
        ];

      programs = {
        nix-index-database.comma.enable = true;
        nix-index.enable = true;
        command-not-found.enable = false;
      };
    };
}
