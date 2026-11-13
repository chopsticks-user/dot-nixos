# checks mkOverlaysFrom against fixture/overlays, evaluation only
{
  lib,
  nixpkgs,
  system,
}:
let
  stock = import nixpkgs { inherit system; };
  pkgs = import nixpkgs {
    inherit system;
    overlays = lib.mkOverlaysFrom ./fixture/overlays;
  };
  added =
    attr:
    map (p: baseNameOf (toString p)) (
      lib.drop (lib.length (stock.hello.patches or [ ])) pkgs.${attr}.patches
    );
in
assert pkgs.greeting.name == "greeting";
assert
  added "hello" == [
    "01-first.patch"
    "02-second.patch"
  ];
# rehello's prev.hello already carries hello/'s patches, since overlays apply in name order
assert lib.drop 2 (added "rehello") == [ "01-only.patch" ];
assert !(builtins.tryEval pkgs.invalid).success;
pkgs.runCommand "lib-packages-test" { } "touch $out"
