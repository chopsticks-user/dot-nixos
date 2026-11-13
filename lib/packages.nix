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

  # every dir/<name>/ changes pkgs.<name>: package.nix defines or replaces it (getting `prev` only if
  # it asks for it), then *.patch files are appended to its patches in file name order
  # shortcut: top-level attributes only (no python3Packages.foo), add scope handling when needed
  mkOverlaysFrom =
    dir:
    map (
      name: final: prev:
      let
        files = builtins.readDir (dir + "/${name}");
        file = dir + "/${name}/package.nix";
        patches = map (patch: dir + "/${name}/${patch}") (
          lib.sort lib.lessThan (
            lib.attrNames (lib.filterAttrs (f: type: type == "regular" && lib.hasSuffix ".patch" f) files)
          )
        );
        base =
          if files ? "package.nix" then
            final.callPackage file (lib.intersectAttrs (lib.functionArgs (import file)) { inherit prev; })
          else
            prev.${name};
      in
      {
        ${name} =
          if !(files ? "package.nix") && patches == [ ] then
            throw "overlay ${toString dir}/${name} has neither package.nix nor *.patch files"
          else if patches == [ ] then
            base
          else
            base.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ patches;
            });
      }
    ) (subdirs dir);
}
