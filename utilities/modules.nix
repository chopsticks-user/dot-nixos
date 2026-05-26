{ lib, ... }:
let
  defineConfigModule =
    namespace: name: moduleFn:
    {
      config,
      lib,
      pkgs, # pkgs is not a specialArgs
      ...
    }@moduleArgs:
    let
      fields = config.${namespace}.${name};
      module = moduleFn (moduleArgs // { inherit fields; });
    in
    {
      imports = module.imports or [ ];
      options.${namespace}.${name} =
        (module.options or { })
        // (lib.optionalAttrs (name != "core") { enable = lib.mkEnableOption name; });
      config = lib.mkIf (name == "core" || (fields.enable or false)) (
        lib.mkMerge [
          (module.configs or { })
          (module.extraConfigs or { })
          (lib.optionalAttrs (namespace == "features" || namespace == "systemProfiles") {
            assertions = map (a: a // { assertion = fields.enable -> a.assertion; }) (module.assertions or [ ]);
          })
          (
            let
              sysDirs = module.persist.system.directories or [ ];
              sysFiles = module.persist.system.files or [ ];
            in
            lib.optionalAttrs
              ((sysDirs != [ ] || sysFiles != [ ]) && (namespace == "features" || namespace == "systemProfiles"))
              {
                environment.persistence."/persist" = {
                  directories = sysDirs;
                  files = sysFiles;
                };
              }
          )
          (
            let
              homePersist = module.persist.home or null;
            in
            lib.optionalAttrs
              (homePersist != null && (namespace == "features" || namespace == "systemProfiles"))
              {
                persist.home."${namespace}.${name}" = homePersist;
              }
          )
        ]
      );
    };
in
{
  mkFeature = defineConfigModule "features";
  mkProfile = defineConfigModule "profiles";
  importFeatures =
    lib.pipe ../features [
      builtins.readDir
      (lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
      ))
      (lib.mapAttrsToList (
        name: _:
        defineConfigModule "features" (lib.removeSuffix ".nix" name) (import (../features + "/${name}"))
      ))
    ]
    ++ lib.pipe ../profiles [
      builtins.readDir
      (lib.filterAttrs (
        name: type: type == "directory" && builtins.pathExists (../profiles + "/${name}/system.nix")
      ))
      (lib.mapAttrsToList (
        name: _: defineConfigModule "systemProfiles" name (import (../profiles + "/${name}/system.nix"))
      ))
    ];
  importProfiles = lib.pipe ../profiles [
    builtins.readDir
    (lib.filterAttrs (name: type: type == "directory"))
    (lib.mapAttrsToList (
      name: _: defineConfigModule "profiles" name (import (../profiles + "/${name}/default.nix"))
    ))
  ];
  mergeImports = files: args: lib.mkMerge (map (f: import f args) files);
}
