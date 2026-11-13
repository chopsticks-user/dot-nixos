# everything that turns overlays into nixpkgs.overlays, for the system and every user:
# first the framework's flake-input overlays and its own overlays/ (always applied, not configurable
# by machines), then the machine's overlays/ under root, which see the framework's packages as prev
root:
{ lib, inputs, ... }:
{
  nixpkgs.overlays = lib.mkMerge [
    [ inputs.llm-agents.overlays.shared-nixpkgs ]
    (lib.mkOverlaysFrom ../overlays)
    (lib.mkAfter (lib.mkOverlaysFrom (root + "/overlays")))
  ];
}
