{
  lib,
  config,
  pkgs,
  inputs,
  constants,
  fields,
  ...
}:
{
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
        constants.directories.system.identity
        "/persist/${constants.directories.system.identity}"
      ];
      defaultSopsFile = ../secrets/hosts/${constants.hostname}.yaml;
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

    time.timeZone = fields.timeZone;

    networking = {
      hostName = constants.hostname;
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
        nvd
        nix-alien
        nixd
        nixfmt
        coreutils
        (pkgs.writeShellScriptBin "nixos-homestrap" (builtins.readFile ../scripts/homestrap.sh))
        (pkgs.writeShellScriptBin "nix-system" (builtins.readFile ../scripts/nix-system.sh))
        (pkgs.writeShellScriptBin "nix-home" (builtins.readFile ../scripts/nix-home.sh))
        (pkgs.writeShellScriptBin "nix" ''
          case "''${1:-}" in
            home) shift; nix-home "$@" ;;
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
