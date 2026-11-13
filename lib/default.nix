# helpers merged into nixpkgs lib; the rest of lib/ (mk-machine, peruser, iso) is not a lib extension
{ lib, ... }:
builtins.foldl' (acc: file: acc // import file { inherit lib; }) { } [
  ./attrs.nix
  ./modules.nix
  ./packages.nix
  ./paths.nix
]
