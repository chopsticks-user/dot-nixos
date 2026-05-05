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
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

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
      (final: _: {
        unreal-engine = final.callPackage ./overlays/unreal-engine/package.nix {};
      })
    ];

    mkPkgsStable = system:
      import nixpkgs-stable {
        inherit system overlays;
      };

    mkIso = system:
      lib.nixosSystem {
        inherit system;
        modules = [
          ./scripts/iso.nix
        ];
      };

    mkHost = hostname: let
      system =
        if builtins.pathExists ./hosts/${hostname}/arch
        then lib.fileContents ./hosts/${hostname}/arch
        else "x86_64-linux";
    in
      lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          pkgs-stable = mkPkgsStable system;
          constants =
            global-constants
            // {
              inherit hostname;
              system = {
                current = system;
              };
            };
        };
        modules =
          [
            {nixpkgs.overlays = overlays;}
            inputs.disko.nixosModules.disko
            ./features
            ./hosts/${hostname}
          ]
          ++ map (username: ./users/${username}/system.nix) usernames;
      };

    mkUser = system: username:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        extraSpecialArgs = {
          inherit inputs;
          pkgs-stable = mkPkgsStable system;
          constants =
            global-constants
            // {
              inherit username;
              home-dir = "/home/${username}";
            };
        };
        modules = [
          ./profiles
          ./users/${username}
        ];
      };

    hostnames = builtins.attrNames (builtins.readDir ./hosts);
    usernames = builtins.attrNames (builtins.readDir ./users);
  in {
    nixosConfigurations =
      (lib.genAttrs hostnames mkHost)
      // lib.listToAttrs (map (
          system:
            lib.nameValuePair "iso-${system}" (mkIso system)
        )
        global-constants.system.supported);
    homeConfigurations = lib.mergeAttrsList (map (
        system:
          lib.listToAttrs (map (
              username:
                lib.nameValuePair "${username}@${system}" (mkUser system username)
            )
            usernames)
      )
      global-constants.system.supported);
  };
}
