{ lib, ... }:
let
  # can't use lib here, need to fix infinite recursion
  hasSuffix =
    suffix: str:
    let
      n = builtins.stringLength str;
      m = builtins.stringLength suffix;
    in
    n >= m && builtins.substring (n - m) m str == suffix;
in
builtins.foldl' (acc: path: acc // import (./. + "/${path}") { inherit lib; }) { } (
  builtins.filter (
    name: hasSuffix ".nix" name && !hasSuffix "-builder.nix" name && name != "default.nix"
  ) (builtins.attrNames (builtins.readDir ./.))
)
