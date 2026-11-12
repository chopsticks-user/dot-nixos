{ lib, ... }:
let
  # class: "nixos" for features/<name>/system.nix, "home" for features/<name>/home.nix
  defineFeature =
    class: name: moduleFn:
    {
      config,
      lib,
      pkgs, # pkgs is not a specialArgs
      ...
    }@moduleArgs:
    let
      fields = config.features.${name};
      module = moduleFn (moduleArgs // { inherit fields; });
      isNixos = class == "nixos";
    in
    {
      imports = module.imports or [ ];
      options.features.${name} =
        (module.options or { })
        // (lib.optionalAttrs (name != "core") { enable = lib.mkEnableOption name; });
      # allowlisting is not enabling, so it skips the enable guard; this keeps pkgs independent of
      # enable flags derived from home-manager, which itself needs pkgs
      config = lib.mkMerge [
        (lib.optionalAttrs (module ? allowUnfree) {
          nixpkgs.config.allowUnfreePackages = module.allowUnfree;
        })
        (lib.mkIf (name == "core" || (fields.enable or false)) (
          lib.mkMerge [
            (module.configs or { })
            (module.extraConfigs or { })
            (lib.optionalAttrs isNixos {
              assertions = map (a: a // { assertion = (fields.enable or true) -> a.assertion; }) (
                module.assertions or [ ]
              );
            })
            (
              let
                sysDirs = module.persist.system.directories or [ ];
                sysFiles = module.persist.system.files or [ ];
              in
              lib.optionalAttrs (isNixos && (sysDirs != [ ] || sysFiles != [ ])) {
                environment.persistence."/persist" = {
                  directories = sysDirs;
                  files = sysFiles;
                };
              }
            )
            (lib.optionalAttrs (isNixos && module ? persist.home) {
              persist.home.${name} = module.persist.home;
            })
          ]
        ))
      ];
    };

  featureNamesWith =
    file:
    lib.attrNames (
      lib.filterAttrs (
        name: type: type == "directory" && builtins.pathExists (../features + "/${name}/${file}")
      ) (builtins.readDir ../features)
    );

  importFeatures =
    class: file:
    map (name: defineFeature class name (import (../features + "/${name}/${file}"))) (
      featureNamesWith file
    );
in
{
  inherit featureNamesWith;
  systemFeatures = importFeatures "nixos" "system.nix";
  homeFeatures = importFeatures "home" "home.nix";
  mergeImports = files: args: lib.mkMerge (map (f: import f args) files);
}
