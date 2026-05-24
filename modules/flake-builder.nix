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
        modules =
          lib.importFeatures
          ++ [
            ../modules/persist-home.nix

            ../hosts/${hostname}/generated.nix
            ../hosts/${hostname}/hardware.nix
            ../hosts/${hostname}/system.nix
            ../hosts/${hostname}/disko.nix

            { nixpkgs.overlays = resolvedOverlays; }
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.nix-index-database.nixosModules.default
          ]
          # todo: remove the check once andromeda has persist.nix
          ++ lib.optionals (builtins.pathExists ../hosts/${hostname}/persist.nix) [
            inputs.impermanence.nixosModules.impermanence
            {
              fileSystems."/persist".neededForBoot = true;
              environment.persistence."/persist" = (import ../hosts/${hostname}/persist.nix) // {
                enable = true;
                hideMounts = true;
              };
            }
          ]
          ++ map (username: {
            imports = [
              ../modules/peruser.nix
              ../users/${username}/system.nix
            ]
            # todo: remove the check once andromeda has persist.nix
            ++
              lib.optionals
                (
                  builtins.pathExists ../users/${username}/persist.nix
                  && builtins.pathExists ../hosts/${hostname}/persist.nix
                )
                [
                  {
                    environment.persistence."/persist".users.${username} = import ../users/${username}/persist.nix;
                  }
                ];
            # todo: append username to constants
            _module.args = {
              inherit username;
              # todo: to be removed once andromeda has persist.nix
              hasPersist = builtins.pathExists ../hosts/${hostname}/persist.nix;
            };
          }) meta.hosts.${hostname}.usernames;
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
              modules = lib.importProfiles ++ [
                ../users/${username}/home.nix
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
