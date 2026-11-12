# root: a directory following the machine layout (see README), returns { nixosConfigurations.<hostName> }
{ inputs, lib }:
root:
let
  optional = name: lib.optional (builtins.pathExists (root + "/${name}")) (root + "/${name}");
  require =
    name:
    if builtins.pathExists (root + "/${name}") then
      root + "/${name}"
    else
      throw "mkMachine: ${toString root}/${name} is required";

  usernames = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (
      if builtins.pathExists (root + "/users") then builtins.readDir (root + "/users") else { }
    )
  );
  userFile = username: name: root + "/users/${username}/${name}";
  persistFile = optional "persist.nix";

  # features with both halves; core is always on
  sharedFeatureNames = lib.remove "core" (
    lib.intersectLists (lib.featureNamesWith "system.nix") (lib.featureNamesWith "home.nix")
  );

  machine = lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules =
      lib.systemFeatures
      ++ [
        ./machine.nix
        ./persist-home.nix
        (require "system.nix")
        (require "hardware.nix")
        (require "disk.nix")
        { sops.defaultSopsFile = require "secrets.yaml"; }

        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.nix-index-database.nixosModules.default
        inputs.home-manager.nixosModules.home-manager

        (
          { config, ... }:
          {
            home-manager = {
              # features set nixpkgs.config per user, which global pkgs forbids
              useGlobalPkgs = false;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              sharedModules = lib.homeFeatures ++ [
                inputs.sops-nix.homeManagerModules.sops
                {
                  nixpkgs.overlays = config.nixpkgs.overlays;
                  home.stateVersion = lib.mkDefault config.system.stateVersion;
                }
              ];
              users = lib.genAttrs usernames (username: {
                imports = [
                  (userFile username "home.nix")
                ]
                ++ lib.optional (builtins.pathExists (userFile username "secrets.yaml")) {
                  sops.defaultSopsFile = userFile username "secrets.yaml";
                };
              });
            };

            # the system half of a feature is on when any user enables its home half
            features = lib.genAttrs sharedFeatureNames (name: {
              enable = lib.mkDefault (
                lib.any (username: config.home-manager.users.${username}.features.${name}.enable) usernames
              );
            });
          }
        )
      ]
      ++ lib.optionals (persistFile != [ ]) [
        inputs.impermanence.nixosModules.impermanence
        {
          fileSystems."/persist".neededForBoot = true;
          environment.persistence."/persist" = import (lib.head persistFile) // {
            enable = true;
            hideMounts = true;
          };
        }
      ]
      ++ map (
        username:
        import ./peruser.nix {
          inherit username;
          userPersist =
            if builtins.pathExists (userFile username "persist.nix") then
              import (userFile username "persist.nix")
            else
              { };
        }
      ) usernames;
  };
in
{
  nixosConfigurations.${machine.config.networking.hostName} = machine;
}
