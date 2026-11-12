# checks mkOverlaysFrom and mkPatchOverlay against fixture/, evaluation only
{
  lib,
  nixpkgs,
  system,
}:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = lib.mkOverlaysFrom ./fixture/overlays ++ [ (lib.mkPatchOverlay ./fixture/patches) ];
  };
  added = map (p: baseNameOf (toString p)) (
    lib.drop (lib.length (import nixpkgs { inherit system; }).hello.patches or 0) pkgs.hello.patches
  );
in
assert pkgs.greeting.name == "greeting";
assert
  added == [
    "01-first.patch"
    "02-second.patch"
  ];
pkgs.runCommand "lib-packages-test" { } "touch $out"
