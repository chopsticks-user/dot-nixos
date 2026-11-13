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

  usernames = lib.subdirs (root + "/users");
  userFile = username: name: root + "/users/${username}/${name}";
  persistFile = optional "system/persist.nix";

  # modules with both halves; core is always on
  sharedModuleNames = lib.remove "core" (
    lib.intersectLists (lib.moduleNamesWith "system.nix") (lib.moduleNamesWith "home.nix")
  );

  machine = lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules =
      lib.systemModules
      ++ [
        (require "system/default.nix")
        (require "hardware/default.nix")
        (require "hardware/disk.nix")
        (import ./overlays.nix root)
        { sops.defaultSopsFile = require "secrets.yaml"; }

        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager

        (
          { config, ... }:
          {
            home-manager = {
              # modules set nixpkgs.config per user, which global pkgs forbids
              useGlobalPkgs = false;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              sharedModules = lib.homeModules ++ [
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

            # the system half of a module is on when any user enables its home half
            modules = lib.genAttrs sharedModuleNames (name: {
              enable = lib.mkDefault (
                lib.any (username: config.home-manager.users.${username}.modules.${name}.enable) usernames
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
