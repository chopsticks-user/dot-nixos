# everything that turns overlays into nixpkgs.overlays, for the system and every user:
# first the framework's own overlays/ (always applied, not configurable by machines),
# then the machine's overlays/ under root, which see the framework's packages as prev
root:
{ lib, ... }:
{
  nixpkgs.overlays = lib.mkMerge [
    (lib.mkOverlaysFrom ../overlays)
    (lib.mkAfter (lib.mkOverlaysFrom (root + "/overlays")))
  ];
}
