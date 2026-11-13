# unit tests for the helpers lib/default.nix merges into lib
{
  lib,
  nixpkgs,
  system,
  test,
}:
let
  stock = import nixpkgs { inherit system; };
  pkgs = import nixpkgs {
    inherit system;
    overlays = lib.mkOverlaysFrom ./fixture/overlays;
  };
  # patch file names a fixture overlay appended to stock hello's
  added =
    attr:
    map (p: baseNameOf (toString p)) (
      lib.drop (lib.length (stock.hello.patches or [ ])) pkgs.${attr}.patches
    );
in
test "lib" {
  testMapAttrNames = {
    expr = lib.mapAttrNames lib.toUpper {
      a = 1;
      b = 2;
    };
    expected = {
      A = 1;
      B = 2;
    };
  };
  testMapAttrNamesEmpty = {
    expr = lib.mapAttrNames lib.toUpper { };
    expected = { };
  };

  testSubdirs = {
    expr = lib.subdirs ./fixture/overlays;
    expected = [
      "greeting"
      "hello"
      "invalid"
      "rehello"
    ];
  };
  testSubdirsIgnoresFiles = {
    expr = lib.subdirs ./fixture/overlays/hello;
    expected = [ ];
  };
  testSubdirsMissing = {
    expr = lib.subdirs ./fixture/missing;
    expected = [ ];
  };

  testOutermostPathsEmpty = {
    expr = lib.outermostPaths [ ];
    expected = [ ];
  };
  testOutermostPathsDuplicates = {
    expr = lib.outermostPaths [
      "a"
      "a"
    ];
    expected = [ "a" ];
  };
  testOutermostPathsNested = {
    expr = lib.outermostPaths [
      "media"
      "media/images"
      "documents"
      "media/images/screenshots"
    ];
    expected = [
      "media"
      "documents"
    ];
  };
  testOutermostPathsParentListedLater = {
    expr = lib.outermostPaths [
      "media/images"
      "media"
    ];
    expected = [ "media" ];
  };
  testOutermostPathsSharedPrefixIsNotNesting = {
    expr = lib.outermostPaths [
      "media"
      "media2"
      "a/b"
      "a/bc"
    ];
    expected = [
      "media"
      "media2"
      "a/b"
      "a/bc"
    ];
  };

  # greeting does not declare prev, so passing it would fail the callPackage call
  testOverlayPackageOnly = {
    expr = pkgs.greeting.name;
    expected = "greeting";
  };
  testOverlayPatchesOnlyInNameOrderSkippingOtherFiles = {
    expr = added "hello";
    expected = [
      "01-first.patch"
      "02-second.patch"
    ];
  };
  # rehello's prev.hello already carries hello/'s patches, since overlays apply in name order
  testOverlayPackageAndPatches = {
    expr = added "rehello";
    expected = [
      "01-first.patch"
      "02-second.patch"
      "01-only.patch"
    ];
  };
  testOverlayNeitherFails = {
    expr = (builtins.tryEval pkgs.invalid).success;
    expected = false;
  };
  testOverlayCount = {
    expr = lib.length (lib.mkOverlaysFrom ./fixture/overlays);
    expected = 4;
  };
  testOverlaysFromMissingDirectory = {
    expr = lib.mkOverlaysFrom ./fixture/missing;
    expected = [ ];
  };

  testModuleNamesBothHalves = {
    expr = lib.all (n: lib.elem n (lib.moduleNamesWith "system.nix")) [
      "core"
      "zsh"
    ];
    expected = true;
  };
  testModuleNamesSystemOnly = {
    expr = {
      system = lib.elem "cli" (lib.moduleNamesWith "system.nix");
      home = lib.elem "cli" (lib.moduleNamesWith "home.nix");
    };
    expected = {
      system = true;
      home = false;
    };
  };
  testModuleNamesHomeOnly = {
    expr = {
      system = lib.elem "theme" (lib.moduleNamesWith "system.nix");
      home = lib.elem "theme" (lib.moduleNamesWith "home.nix");
    };
    expected = {
      system = false;
      home = true;
    };
  };
  testOneModulePerHalf = {
    expr = {
      system = lib.length lib.systemModules == lib.length (lib.moduleNamesWith "system.nix");
      home = lib.length lib.homeModules == lib.length (lib.moduleNamesWith "home.nix");
    };
    expected = {
      system = true;
      home = true;
    };
  };
}
