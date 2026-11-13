{
  description = "dot-nixos: a NixOS framework that builds one machine with any number of users";

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
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-index-database.follows = "nix-index-database";
      };
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
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      supported = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      lib = inputs.nixpkgs.lib.extend (
        final: prev:
        let
          utils = import ./lib { lib = final; };
          collisions = builtins.attrNames (builtins.intersectAttrs prev utils);
        in
        if collisions == [ ] then
          utils
        else
          throw "lib/ helpers collide with nixpkgs lib: ${prev.concatStringsSep ", " collisions}"
      );
    in
    {
      lib.mkMachine = import ./lib/mk-machine.nix { inherit inputs lib; };

      checks = lib.genAttrs (lib.filter (lib.hasSuffix "-linux") supported) (
        system:
        let
          test = import ./tests/harness.nix {
            inherit lib;
            pkgs = inputs.nixpkgs.legacyPackages.${system};
          };
        in
        {
          lib = import ./tests/lib.nix {
            inherit lib system test;
            inherit (inputs) nixpkgs;
          };
        }
      );

      formatter = lib.genAttrs supported (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations =
        # examples are standalone flakes; calling their outputs with this flake keeps the root able to
        # build and check them against the working tree without going through their lock files
        lib.mergeAttrsList (
          map
            (name: ((import ./examples/${name}/flake.nix).outputs { dot-nixos = self; }).nixosConfigurations)
            [
              "andromeda"
              "perseus"
            ]
        )
        // lib.listToAttrs (
          map (
            system:
            lib.nameValuePair "iso-${system}" (
              lib.nixosSystem {
                inherit system;
                modules = [ ./lib/iso.nix ];
              }
            )
          ) (lib.filter (lib.hasSuffix "-linux") supported)
        );
    };
}
