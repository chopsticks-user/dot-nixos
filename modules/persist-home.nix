{ lib, ... }:
{
  options.persist.home = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.functionTo (
        lib.types.submodule {
          options = {
            directories = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              default = [ ];
            };
            files = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              default = [ ];
            };
          };
        }
      )
    );
  };
}
