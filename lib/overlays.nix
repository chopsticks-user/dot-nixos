# everything that turns overlays and patches into nixpkgs.overlays, for the system and every user:
# first the framework's own overlays/ and patches/ (always applied, not configurable by machines),
# then the machine's overlays/ and patches/ under root, which see the framework's packages as prev
root:
{ lib, ... }:
let
  layer =
    dir:
    lib.mkOverlaysFrom (dir + "/overlays")
    ++ lib.optional (builtins.pathExists (dir + "/patches")) (lib.mkPatchOverlay (dir + "/patches"));
in
{
  nixpkgs.overlays = lib.mkMerge [
    (layer ./..)
    (lib.mkAfter (layer root))
  ];
}
