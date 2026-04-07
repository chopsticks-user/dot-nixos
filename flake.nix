{
  description = "NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... } @ inputs:
    let
      lib = nixpkgs.lib;

      mkHost = hostname:
        let
          system =
            if builtins.pathExists ./hosts/${hostname}/arch
            then lib.fileContents ./hosts/${hostname}/arch
            else "x86_64-linux";
        in lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./features
            ./hosts/${hostname}/system.nix
            ./hosts/${hostname}/hardware.nix
          ];
        };

      systems = [ "x86_64-linux" "aarch64-linux" ];

      mkUser = system: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./users/${username}/home.nix
          ];
        };

      hostnames = builtins.attrNames (builtins.readDir ./hosts);
      usernames = builtins.attrNames (builtins.readDir ./users);

    in {
      nixosConfigurations = lib.genAttrs hostnames mkHost;
      homeConfigurations = lib.mergeAttrsList (map (system:
        lib.listToAttrs (map (username:
          lib.nameValuePair "${username}@${system}" (mkUser system username)
        ) usernames)
      ) systems);
    };
}