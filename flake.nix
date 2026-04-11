{
  description = "NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;

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
            inputs.disko.nixosModules.disko
            ./features
            ./hosts/${hostname}
          ]
          ++ map (username: ./users/${username}/core/info.nix) usernames;
      };

    mkUser = system: username:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs;
          constants =
            global-constants
            // {
              inherit username;
              home-dir = "/home/${username}";
            };
        };
        modules = [
          ./users/${username}
        ];
      };

    hostnames = builtins.attrNames (builtins.readDir ./hosts);
    usernames = builtins.attrNames (builtins.readDir ./users);
  in {
    nixosConfigurations = lib.genAttrs hostnames mkHost;
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
