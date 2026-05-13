{
  description = "NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib.extend (
        final: prev: {
          utils = import ./utilities { lib = final; };
        }
      );

      global-constants = {
        config-path = "$HOME/.nixos";
        system = {
          supported = [
            "x86_64-linux"
            "x86_64-darwin"
            "aarch64-linux"
            "aarch64-darwin"
          ];
          default = "x86_64-linux";
        };
        default-password = "password";
      };

      # todo: bulk import and accept arguments from system or user callsite
      overlays = [
        (final: prev: {
          unreal-engine = final.callPackage ./overlays/unreal-engine/package.nix {
          };
        })
        (final: prev: {
          bottles = final.callPackage ./overlays/bottles/package.nix {
            inherit prev;
          };
        })
        (final: prev: {
          openldap = final.callPackage ./overlays/openldap/package.nix {
            inherit prev;
          };
        })
      ];

      mkPkgsStable =
        system:
        import nixpkgs-stable {
          inherit system overlays;
        };

      mkIso =
        system:
        lib.nixosSystem {
          inherit system;
          modules = [ ./scripts/iso.nix ];
        };

      mkHost =
        hostname:
        let
          system = lib.fileContents ./data/${hostname}.arch;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-stable = mkPkgsStable system;
            constants = global-constants // {
              inherit hostname;
              system = {
                current = system;
              };
            };
          };
          modules = [
            { nixpkgs.overlays = overlays; }
            inputs.disko.nixosModules.disko
            ./features
            ./hosts/${hostname}
            inputs.nix-index-database.nixosModules.default
          ]
          ++ map (username: ./users/${username}/system.nix) usernames;
        };

      mkUser =
        system:
        let
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          vars = pkgs.requireFile {
            name = "variables";
            sha256 = lib.fileContents ./data/variables.hash;
            message = ''
              Run ./scripts/gen_vars.sh
            '';
            hashMode = "recursive";
          };
        in
        username:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
            pkgs-stable = mkPkgsStable system;
            constants =
              global-constants
              // {
                inherit username;
                homeDirectory = "/home/${username}";
              }
              // (builtins.fromJSON (
                # have a doppler account setup correctly and run "./scripts/gen-vars.sh"
                builtins.readFile "${vars}/${username}.json"
              ));
            utils = import ./utilities { inherit (nixpkgs) lib; };
          };
          modules = [
            ./profiles
            ./users/${username}
          ];
        };

      hostnames = builtins.attrNames (builtins.readDir ./hosts);
      usernames = builtins.attrNames (builtins.readDir ./users);
    in
    {
      formatter = lib.genAttrs global-constants.system.supported (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      nixosConfigurations =
        (lib.genAttrs hostnames mkHost)
        // lib.listToAttrs (
          map (system: lib.nameValuePair "iso-${system}" (mkIso system)) global-constants.system.supported
        );

      homeConfigurations = lib.mergeAttrsList (
        map (
          system:
          lib.listToAttrs (
            map (username: lib.nameValuePair "${username}@${system}" (mkUser system username)) usernames
          )
        ) global-constants.system.supported
      );

      templates = {
        development = {
          path = ./templates/development;
          description = "";
          welcomeText = "";
        };
        development-fhs = {
          path = ./templates/development-fhs;
          description = "";
          welcomeText = "";
        };
        default = self.templates.development;
      };
    };
}
