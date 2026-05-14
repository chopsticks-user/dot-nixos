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

      meta = builtins.fromJSON (builtins.readFile ./meta.json);

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
          system = meta.system.hosts.${hostname};
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-stable = mkPkgsStable system;
            constants = meta // {
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
        system: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs =
            import nixpkgs {
              inherit system overlays;
            }
            // {
              inherit lib;
            };

          extraSpecialArgs = {
            inherit inputs;
            pkgs-stable = mkPkgsStable system;
            constants = meta // {
              inherit username;
              homeDirectory = "/home/${username}";
            };
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
      formatter = lib.genAttrs meta.system.supported (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      nixosConfigurations =
        (lib.genAttrs hostnames mkHost)
        // lib.listToAttrs (
          map (system: lib.nameValuePair "iso-${system}" (mkIso system)) meta.system.supported
        );

      homeConfigurations = lib.mergeAttrsList (
        map (
          system:
          lib.listToAttrs (
            map (username: lib.nameValuePair "${username}@${system}" (mkUser system username)) usernames
          )
        ) meta.system.supported
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
