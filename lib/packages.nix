{ lib, ... }:
let
  # dir/<name>/package.nix is called with `prev` plus args and becomes pkgs.<name>
  mkOverlayFrom = dir: name: args: final: prev: {
    ${name} = final.callPackage (dir + "/${name}/package.nix") ({ inherit prev; } // args);
  };

  subdirs =
    dir:
    lib.optionals (builtins.pathExists dir) (
      lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dir))
    );
in
{
  inherit mkOverlayFrom subdirs;

  # opt-in overlays shipped with the framework
  mkOverlay = mkOverlayFrom ../overlays;

  # every dir/<name>/package.nix, without args
  mkOverlaysFrom = dir: map (name: mkOverlayFrom dir name { }) (subdirs dir);

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
