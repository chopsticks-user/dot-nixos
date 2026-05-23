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
          (module.extraConfig or { })
          {
            assertions = map (a: a // { assertion = fields.enable -> a.assertion; }) (module.assertions or [ ]);
          }
        ]
      );
    };
in
{
  mkFeature = defineConfigModule "features";
  mkProfile = defineConfigModule "profiles";
  importConfigModules =
    namespace:
    lib.pipe ../${namespace} [
      builtins.readDir
      (lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
      ))
      (lib.mapAttrsToList (
        name: _:
        defineConfigModule namespace (lib.removeSuffix ".nix" name) (import (../${namespace} + "/${name}"))
      ))
    ];
}
