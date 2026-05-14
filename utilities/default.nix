{ lib, ... }:
let
  modules = import ./modules.nix { inherit lib; };
  packages = import ./packages.nix { inherit lib; };
in
modules // packages
