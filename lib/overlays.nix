# everything that turns overlays and patches into nixpkgs.overlays; users only enable or drop in files
# root: the machine directory, scanned for overlays/<name>/package.nix and patches/<attr>/*.patch
root:
{ lib, config, ... }:
let
  cfg = config.overlays;
  patchesDir = root + "/patches";
in
{
  # framework overlays are opt-in because some change existing packages
  options.overlays = lib.genAttrs (lib.subdirs ../overlays) (
    name:
    lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "the ${name} overlay from dot-nixos overlays/";
          args = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Arguments passed to overlays/${name}/package.nix";
          };
        };
      };
      default = { };
    }
  );

  config.nixpkgs.overlays = lib.mkMerge [
    (lib.mapAttrsToList (name: o: lib.mkOverlay name o.args) (lib.filterAttrs (_: o: o.enable) cfg))
    # the machine's own overlays and patches come after, so they can replace framework ones
    (lib.mkAfter (
      lib.mkOverlaysFrom (root + "/overlays")
      ++ lib.optional (builtins.pathExists patchesDir) (lib.mkPatchOverlay patchesDir)
    ))
  ];
}
