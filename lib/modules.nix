{ lib, ... }:
let
  # class: "nixos" for modules/<name>/system.nix, "home" for modules/<name>/home.nix
  defineModule =
    class: name: moduleFn:
    {
      config,
      options,
      lib,
      pkgs, # pkgs is not a specialArgs
      ...
    }@moduleArgs:
    let
      fields = config.modules.${name};
      module = moduleFn (moduleArgs // { inherit fields; });
      isNixos = class == "nixos";
    in
    {
      imports = module.imports or [ ];
      options.modules.${name} =
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
              # environment.persistence only exists when the machine imports impermanence
              lib.optionalAttrs
                (isNixos && options ? environment.persistence && (sysDirs != [ ] || sysFiles != [ ]))
                {
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

  moduleNamesWith =
    file:
    lib.attrNames (
      lib.filterAttrs (
        name: type: type == "directory" && builtins.pathExists (../modules + "/${name}/${file}")
      ) (builtins.readDir ../modules)
    );

  importModules =
    class: file:
    map (name: defineModule class name (import (../modules + "/${name}/${file}"))) (
      moduleNamesWith file
    );
in
{
  inherit defineModule moduleNamesWith;
  systemModules = importModules "nixos" "system.nix";
  homeModules = importModules "home" "home.nix";
}
