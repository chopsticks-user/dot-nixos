{ ... }:
let
  defineConfigModule =
    namespace: name:
    {
      options ? { },
      configs,
      extraConfig ? { },
      assertions ? [ ],
      imports ? [ ],
    }:
    {
      config,
      lib,
      ...
    }@moduleArgs:
    let
      fields = config.${namespace}.${name};
    in
    {
      imports = imports;

      options.${namespace}.${name} = {
        enable = lib.mkEnableOption name;
      }
      // options;

      config = lib.mkIf fields.enable (
        lib.mkMerge [
          (configs (moduleArgs // { inherit fields; }))
          extraConfig
          {
            assertions = map (a: a // { assertion = fields.enable -> a.assertion; }) assertions;
          }
        ]
      );
    };
in
{
  mkProfile = defineConfigModule "profiles";
  mkFeature = defineConfigModule "features";
}
