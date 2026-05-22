{
  config,
  lib,
  pkgs,
  inputs,
  constants,
  ...
}@args:
(lib.mkFeature "core" {
  options = { };

  configs =
    { ... }:
    {
      system.stateVersion = constants.version;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        cores = 0;
        max-jobs = "auto";
      };

      boot.kernelPackages = pkgs."linuxPackages_${constants.kernel}";

      environment.systemPackages =
        let
          inherit (inputs.nix-alien.packages.${constants.system}) nix-alien;
          btop =
            if constants.gpu == "nvidia" then
              pkgs.btop-cuda
            else if constants.gpu == "amd" then
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

          # secret management
          age
          ssh-to-age
          sops

          # miscellaneous
          wl-clipboard
          wev
          just
          (writeShellScriptBin "nixos-homestrap" (builtins.readFile ../scripts/install.sh))
        ];

      programs = {
        nix-index-database.comma.enable = true;
        nix-index.enable = true;
        command-not-found.enable = false;
        zsh.enable = true;
      };

      sops = {
        age.sshKeyPaths = [
          constants.directories.system.identity
          "/persist/${constants.directories.system.identity}"
        ];
        defaultSopsFile = ../secrets/hosts/${constants.hostname}.yaml;

        secrets = {
          "password/root" = {
            neededForUsers = true;
          };
        };
      };

      users.users.root = {
        hashedPasswordFile = config.sops.secrets."password/root".path;
      };
    };
})
  args
