{
  lib,
  fields,
  constants,
  pkgs,
  ...
}:
{
  options = lib.mapAttrs (
    _: _:
    lib.mkOption {
      type = lib.types.nullOr (
        lib.types.either lib.types.package (
          lib.types.submodule {
            options = {
              package = lib.mkOption {
                type = lib.types.nullOr lib.types.package;
                default = null;
              };
              desktopEntry = lib.mkOption {
                type = lib.types.nullOr (lib.types.either lib.types.str lib.types.attrs);
                default = null;
              };
            };
          }
        )
      );
      default = null;
    }
  ) constants.mime;

  configs =
    let
      resolve =
        category:
        let
          val = fields.${category};
        in
        if val == null then
          {
            pkg = null;
            entry = null;
          }
        else if val ? package then
          {
            pkg = val.package;
            entry = val.desktopEntry;
          }
        else
          {
            pkg = val;
            entry = null;
          };
    in
    {
      assertions = lib.concatLists (
        lib.mapAttrsToList (
          category: meta:
          let
            r = resolve category;
          in
          lib.optional (r.pkg != null) {
            assertion =
              r.entry != null
              || builtins.pathExists "${r.pkg}/share/applications/${
                if r.pkg.meta ? mainProgram then r.pkg.meta.mainProgram else r.pkg.pname
              }.desktop";
            message = "${r.pkg.pname} does not have a desktop entry. Specify one via desktopEntry.";
          }
        ) constants.mime
      );

      home.packages =
        lib.concatLists (
          lib.mapAttrsToList (
            category: meta:
            let
              r = resolve category;
            in
            lib.optional (r.pkg != null) r.pkg
          ) constants.mime
        )
        ++ [
          (pkgs.writeShellScriptBin "open" ''
            xdg-open "$@"
          '')
        ];

      xdg = {
        configFile."mimeapps.list".force = true;
        desktopEntries = lib.filterAttrs (_: v: v != null) (
          lib.mapAttrs (
            category: meta:
            let
              r = resolve category;
            in
            if r.pkg != null && r.entry != null && builtins.isAttrs r.entry then r.entry else null
          ) constants.mime
        );
        mimeApps = {
          enable = true;
          defaultApplications = lib.mergeAttrsList (
            lib.mapAttrsToList (
              category: meta:
              let
                r = resolve category;
                desktopName =
                  if r.entry != null && builtins.isString r.entry then
                    r.entry
                  else if r.entry != null && builtins.isAttrs r.entry then
                    category
                  else if r.pkg.meta ? mainProgram then
                    r.pkg.meta.mainProgram
                  else
                    r.pkg.pname;
              in
              lib.optionalAttrs (r.pkg != null) (lib.genAttrs meta.matches (_: "${desktopName}.desktop"))
            ) constants.mime
          );
        };
      };
    };
}
