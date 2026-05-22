# standalone, not imported by the utilities module
{
  inputs,
  overlays ? { },
  templates ? { },
  apps ? { },
  ...
}:
let
  meta = builtins.fromJSON (builtins.readFile ../meta.json);

  lib = inputs.nixpkgs.lib.extend (
    final: prev:
    let
      utils = import ../utilities { lib = final; };
      collisions = builtins.attrNames (builtins.intersectAttrs prev utils);
    in
    if collisions == [ ] then
      utils
    else
      throw "utilities collide with lib: ${prev.concatStringsSep ", " collisions}"
  );

  resolvedOverlays = map (
    {
      name,
      args ? { },
    }:
    lib.mkOverlay name args
  ) overlays;

  mkSpecializedPackage = upstream: system: lib.mkSpecializedPackage upstream system resolvedOverlays;
in
{
  formatter = lib.genAttrs meta.supported (
    system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree
  );

  nixosConfigurations =
    (lib.genAttrs (builtins.attrNames (builtins.readDir ../hosts)) (
      hostname:
      let
        system = meta.hosts.${hostname}.system;
      in
      lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          pkgs-stable = mkSpecializedPackage inputs.nixpkgs-stable system;
          constants =
            lib.recursiveUpdate meta {
              inherit hostname;
            }
            // meta.hosts.${hostname};
        };
        modules = [
          ../features
          ../hosts/${hostname}
          { nixpkgs.overlays = resolvedOverlays; }
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.nix-index-database.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
        ]
        ++ map (
          username:
          let
            coreModule =
              {
                config,
                pkgs,
                constants,
                ...
              }:
              {
                sops = {
                  secrets = {
                    "password/${username}" = {
                      neededForUsers = true;
                    };
                  };
                };

                users.users.${username} =
                  let
                    userMeta = constants.users."${username}";
                  in
                  {
                    inherit (userMeta) description;
                    isNormalUser = true;
                    hashedPasswordFile = config.sops.secrets."password/${username}".path;
                    extraGroups = userMeta.groups;
                    shell = pkgs.${userMeta.shell};
                  };
              };
          in
          {
            imports = [
              coreModule
              ../users/${username}/system.nix
            ];
            # todo: append username to constants
            _module.args = {
              inherit username;
            };
          }
        ) meta.hosts.${hostname}.usernames;
      }
    ))
    // lib.listToAttrs (
      map (
        system:
        lib.nameValuePair "iso-${system}" (
          lib.nixosSystem {
            inherit system;
            specialArgs = { };
            modules = [ ./iso.nix ];
          }
        )
      ) meta.supported
    );

  homeConfigurations = lib.mergeAttrsList (
    map (
      system:
      lib.listToAttrs (
        map (
          username:
          lib.nameValuePair "${username}@${system}" (
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = (mkSpecializedPackage inputs.nixpkgs system) // {
                inherit lib;
              };

              extraSpecialArgs = {
                inherit inputs;
                pkgs-stable = mkSpecializedPackage inputs.nixpkgs-stable system;
                constants =
                  let
                    homeDirectory = "/home/${username}";
                  in
                  lib.recursiveUpdate meta {
                    inherit username homeDirectory;
                    directories.home = lib.mapAttrs (_: path: "${homeDirectory}/${path}") meta.directories.home;
                  }
                  // meta.users.${username};
              };
              modules = [
                ../profiles
                ../users/${username}
                inputs.sops-nix.homeManagerModules.sops
              ];
            }
          )
        ) (builtins.attrNames (builtins.readDir ../users))
      )
    ) meta.supported
  );

  templates =
    let
      actualTemplates = lib.mapAttrs (
        name: tmpl: { path = ../templates/${name}; } // (removeAttrs tmpl [ "default" ])
      ) templates;
      templateList = builtins.attrNames templates;
      default =
        let
          defaultList = builtins.filter (name: templates.${name}.default or false) templateList;
        in
        if builtins.length defaultList > 1 then
          throw "Only 1 template can be marked as default: ${builtins.toJSON defaultList}"
        else if defaultList != [ ] then
          builtins.head defaultList
        else if builtins.length templateList == 1 then
          builtins.head templateList
        else
          null;
    in
    actualTemplates
    // lib.optionalAttrs (default != null) {
      default = actualTemplates.${default};
    };

  inherit apps;
}
