{
  lib,
  config,
  options,
  pkgs,
  fields,
  ...
}:
let
  dirs = config.machine.directories;

  # under impermanence sops decrypts before /persist is bind-mounted, so it reads the key there
  hostIdentity = lib.optionalString (options.environment ? persistence) "/persist" + dirs.identity;

  # build-time facts the scripts need, overridable from the environment
  scriptEnv = ''
    export NIXOS_FLAKE_DIR="''${NIXOS_FLAKE_DIR:-${dirs.nixos}}"
    export NIXOS_HOME_IDENTITY="''${NIXOS_HOME_IDENTITY:-${dirs.home.identity}}"
    export NIXOS_HOST_IDENTITY="${hostIdentity}"
    export NIXOS_USERS="${lib.concatStringsSep " " (lib.attrNames config.home-manager.users)}"
  '';
  script =
    name: runtimeInputs: file:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = scriptEnv + builtins.readFile file;
    };

  # paths nested in another listed path are covered by it, and impermanence rejects overlaps
  outermost = paths: lib.filter (p: !lib.any (q: lib.hasPrefix "${q}/" p) paths) (lib.unique paths);
in
{
  imports = [
    ./machine-options.nix
    ./persist-options.nix
  ];

  options = {
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

  assertions = [
    {
      assertion = dirOf dirs.home.identity != ".";
      message = "machine.directories.home.identity must be inside a directory of home, which is persisted with mode 0700";
    }
  ];

  configs = {
    sops = {
      age.sshKeyPaths = [ hostIdentity ];
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

    environment.systemPackages = with pkgs; [
      git
      age
      ssh-to-age
      sops
      (script "nixos-homestrap" [
        git
        openssh
      ] ../../scripts/homestrap.sh)
      (script "nixos-secrets" [
        sops
        ssh-to-age
        openssh
        gnutar
        gzip
      ] ../../scripts/secrets.sh)
      (script "nix-system" [ nvd ] ../../scripts/nix-system.sh)
      (writeShellScriptBin "nix" ''
        case "''${1:-}" in
          system) shift; nix-system "$@" ;;
          *) exec ${pkgs.nix}/bin/nix "$@" ;;
        esac
      '')
    ];
  };

  # every user keeps what the framework itself places in home: the user key, the flake checkout
  # and the well-known data directories
  persist.home = {
    directories = [
      {
        directory = dirOf dirs.home.identity;
        mode = "0700";
      }
    ]
    ++ lib.optional (lib.hasPrefix "$HOME/" dirs.nixos) (lib.removePrefix "$HOME/" dirs.nixos)
    ++ outermost (
      lib.attrValues (
        lib.getAttrs [
          "documents"
          "download"
          "projects"
          "media"
          "pictures"
          "music"
          "videos"
          "wallpapers"
          "screenshots"
          "screencasts"
        ] dirs.home
      )
    );
    files = [ ];
  };
}
