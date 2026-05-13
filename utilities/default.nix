{ lib, ... }:
let
  modules = import ./modules.nix { inherit lib; };
in
modules
