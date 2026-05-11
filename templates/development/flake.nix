{
  description = ""; # edit

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # edit as needed
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      meta = {
        name = ""; # edit
        ide = {
          name = ""; # edit
          exec = ""; # edit
          icon = ""; # edit
        };
        flakeDir = ""; # edit as needed
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
          ];

          shellHook = "";
        };
        apps =
          let
            desktopEntry = "$HOME/.local/share/applications/${meta.ide.exec}-${meta.name}.desktop";
            developCmdArgumentPath =
              "path:$PROJECT_PATH" + nixpkgs.lib.optionalString (meta.flakeDir != "") "/${meta.flakeDir}";
          in
          {
            install = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "install" ''
                  PROJECT_PATH="''${1:-$(git rev-parse --show-toplevel)}"
                  mkdir -p ~/.local/share/applications
                  cat > ${desktopEntry} <<DESKTOP
                  [Desktop Entry]
                  Name=${meta.ide.name} (${meta.name})
                  Exec=nix develop ${developCmdArgumentPath} -c ${meta.ide.exec} $PROJECT_PATH
                  Icon=${meta.ide.icon}
                  Type=Application
                  Categories=Development;
                  DESKTOP
                ''
              );
            };
            uninstall = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "uninstall" ''
                  rm -f ${desktopEntry}
                ''
              );
            };
          };
      }
    )
    // {
      # system-independent outputs
    };
}
