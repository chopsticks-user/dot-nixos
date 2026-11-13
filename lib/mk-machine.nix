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

  requiredFiles = [
    "system/default.nix"
    "hardware/default.nix"
    "hardware/disk.nix"
    "secrets.yaml"
  ];
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
              # one nixpkgs for the system and every user; users allow unfree names through user.allowUnfree
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              sharedModules = lib.homeModules ++ [
                inputs.sops-nix.homeManagerModules.sops
                { home.stateVersion = lib.mkDefault config.system.stateVersion; }
              ];
              users = lib.genAttrs usernames (username: {
                imports = [
                  (require "users/${username}/home.nix")
                ]
                ++ lib.optional (builtins.pathExists (userFile username "secrets.yaml")) {
                  sops.defaultSopsFile = userFile username "secrets.yaml";
                };
              });
            };

            # a plain value read only when a package's license is checked, so pkgs stays independent
            # of which Home Manager config exists
            nixpkgs.config.allowUnfreePackages = lib.concatMap (
              username: config.home-manager.users.${username}.user.allowUnfree
            ) usernames;

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
# checked up front: some are otherwise only read late, such as home.nix once home-manager evaluates
# that user, or secrets.yaml once sops does
lib.deepSeq (map require (requiredFiles ++ map (username: "users/${username}/home.nix") usernames))
  {
    nixosConfigurations.${machine.config.networking.hostName} = machine;
  }
