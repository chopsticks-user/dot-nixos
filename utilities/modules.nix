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
      persist = module.persist or { };
      systemPersist = persist.system or { };
      homePersistFn = persist.home or null; # username -> { directories, files }
      sysDirs = systemPersist.directories or [ ];
      sysFiles = systemPersist.files or [ ];
      isEnabled = name == "core" || (fields.enable or false);
      hasSystemPersist = sysDirs != [ ] || sysFiles != [ ];
      key = "${namespace}.${name}";
    in
    {
      imports = module.imports or [ ];
      options.${namespace}.${name} =
        (module.options or { })
        // (lib.optionalAttrs (name != "core") { enable = lib.mkEnableOption name; });
      config = lib.mkIf isEnabled (
        lib.mkMerge [
          (module.configs or { })
          (module.extraConfigs or { })
          (lib.optionalAttrs (namespace == "features" || namespace == "systemProfiles") {
            assertions = map (a: a // { assertion = fields.enable -> a.assertion; }) (module.assertions or [ ]);
          })
          (lib.optionalAttrs (hasSystemPersist && (namespace == "features" || namespace == "systemProfiles"))
            {
              environment.persistence."/persist" = {
                directories = sysDirs;
                files = sysFiles;
              };
            }
          )
          (lib.optionalAttrs
            (homePersistFn != null && (namespace == "features" || namespace == "systemProfiles"))
            {
              persist.home.${key} = homePersistFn;
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
}
