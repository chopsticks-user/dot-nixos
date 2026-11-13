{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-index-database.nixosModules.default ];

  options = { };

  configs = {
    environment.systemPackages =
      let
        inherit (inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}) nix-alien;
        btop =
          if lib.elem "nvidia" config.services.xserver.videoDrivers then
            pkgs.btop-cuda
          else if lib.elem "amdgpu" config.services.xserver.videoDrivers then
            pkgs.btop-rocm
          else
            pkgs.btop;
      in
      with pkgs;
      [
        # nix tooling
        nvd
        nix-alien
        nixd
        nixfmt

        # system administration & monitoring
        efibootmgr
        psmisc
        lshw
        inotify-tools
        fastfetch
        ncdu
        btop

        # text and data, coreutils already includes sort, uniq, cut
        ripgrep
        sd
        fd
        jq
        yq
        gawk
        findutils # xargs
        gnused

        # files & directories
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
        just
      ];

    programs = {
      nix-index-database.comma.enable = true;
      nix-index.enable = true;
      command-not-found.enable = false;
    };
  };
}
