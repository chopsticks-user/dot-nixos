{ lib, ... }:
let
  subdirs =
    dir:
    lib.optionals (builtins.pathExists dir) (
      lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dir))
    );
in
{
  inherit subdirs;

  # every dir/<name>/package.nix becomes pkgs.<name>; it gets `prev` only if it asks for it
  mkOverlaysFrom =
    dir:
    map (
      name: final: prev:
      let
        file = dir + "/${name}/package.nix";
      in
      {
        ${name} = final.callPackage file (
          lib.intersectAttrs (lib.functionArgs (import file)) { inherit prev; }
        );
      }
    ) (subdirs dir);

  # dir/<attr>/*.patch are appended to pkgs.<attr>'s patches in file name order
  # shortcut: top-level attributes only (no python3Packages.foo), add scope handling when needed
  mkPatchOverlay =
    dir: final: prev:
    lib.genAttrs (subdirs dir) (
      attr:
      prev.${attr}.overrideAttrs (old: {
        patches =
          (old.patches or [ ])
          ++ map (file: dir + "/${attr}/${file}") (
            lib.sort lib.lessThan (
              lib.attrNames (
                lib.filterAttrs (file: type: type == "regular" && lib.hasSuffix ".patch" file) (
                  builtins.readDir (dir + "/${attr}")
                )
              )
            )
          );
      })
    );
}
