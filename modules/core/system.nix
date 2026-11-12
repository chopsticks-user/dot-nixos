{
  lib,
  config,
  pkgs,
  inputs,
  fields,
  ...
}:
{
  imports = [
    ./machine-options.nix
    ./persist-options.nix
  ];

  options = {
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/New_York";
    };
    ethernet = {
      priority = lib.mkOption {
        type = lib.types.int;
        default = 100;
      };
    };
    wifi = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            priority = lib.mkOption {
              type = lib.types.int;
              default = 10;
            };
            autoconnect = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
          };
        }
      );
      default = { };
    };
  };

  configs = {
    sops = {
      age.sshKeyPaths = [
        # todo: only consider /persist once andromeda supports impermanence
        config.machine.directories.identity
        "/persist${config.machine.directories.identity}"
      ];
      secrets = {
        "password/root" = {
          neededForUsers = true;
        };
      }
      // lib.listToAttrs (
        lib.flatten (
          lib.mapAttrsToList (name: _w: [
            (lib.nameValuePair "networking/wifi/${name}/ssid" { })
            (lib.nameValuePair "networking/wifi/${name}/password" { })
          ]) fields.wifi
        )
      );
      templates = {
        "networking.env".content = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: _w: ''
            WIFI_${lib.toUpper name}_SSID=${config.sops.placeholder."networking/wifi/${name}/ssid"}
            WIFI_${lib.toUpper name}_PASSWORD=${config.sops.placeholder."networking/wifi/${name}/password"}
          '') fields.wifi
        );
      };
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      cores = 0;
      max-jobs = "auto";
    };

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    time.timeZone = fields.timeZone;

    networking = {
      firewall.enable = true;
      networkmanager = {
        enable = true;
        ensureProfiles = {
          environmentFiles = lib.mkIf (fields.wifi != { }) [
            config.sops.templates."networking.env".path
          ];
          profiles = {
            ethernet = {
              connection = {
                id = "ethernet";
                type = "ethernet";
                autoconnect = "true";
                autoconnect-priority = toString fields.ethernet.priority;
              };
              ipv4.method = "auto";
            };
          }
          // (lib.mapAttrs (name: w: {
            connection = {
              id = name;
              type = "wifi";
              autoconnect = lib.boolToString w.autoconnect;
              autoconnect-priority = toString w.priority;
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$WIFI_${lib.toUpper name}_SSID";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$WIFI_${lib.toUpper name}_PASSWORD";
            };
            ipv4.method = "auto";
          }) fields.wifi);
        };
      };
    };

    users.users.root = {
      hashedPasswordFile = config.sops.secrets."password/root".path;
    };

    environment.systemPackages =
      let
        scriptEnv = ''
          export NIXOS_FLAKE_DIR="''${NIXOS_FLAKE_DIR:-${config.machine.directories.nixos}}"
          export NIXOS_HOME_IDENTITY="''${NIXOS_HOME_IDENTITY:-${config.machine.directories.home.identity}}"
        '';
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
        # core & nix tooling
        home-manager
        nvd
        nix-alien
        nixd
        nixfmt
        coreutils
        (pkgs.writeShellScriptBin "nixos-homestrap" (
          scriptEnv + builtins.readFile ../../scripts/homestrap.sh
        ))
        (pkgs.writeShellScriptBin "nix-system" (scriptEnv + builtins.readFile ../../scripts/nix-system.sh))
        (pkgs.writeShellScriptBin "nix" ''
          case "''${1:-}" in
            system) shift; nix-system "$@" ;;
            *) exec ${pkgs.nix}/bin/nix "$@" ;;
          esac
        '')

        # system administration & monitoring
        efibootmgr
        psmisc
        lshw
        inotify-tools
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
      ];

    programs = {
      nix-index-database.comma.enable = true;
      nix-index.enable = true;
      command-not-found.enable = false;
      zsh.enable = true;
    };
  };
}
