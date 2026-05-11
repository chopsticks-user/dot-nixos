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
        desktopPath = "$HOME/.local/share/applications"; # edit as needed
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        fhs =
          let

          in
          pkgs.buildFHSEnv {
            name = "${meta.name}";
            targetPkgs = p: (with p; [ ]);

            runScript = pkgs.writeShellScript "${meta.name}-fhs" ''
              if [ $# -eq 0 ]; then
                exec "$(getent passwd "$USER" | cut -d: -f7)"
              else
                exec "$@"
              fi
            '';

            profile = "";
          };
      in
      {
        devShells.default = fhs.env;
        apps =
          let
            desktopEntry = "${meta.desktopPath}/${meta.ide.exec}-${meta.name}.desktop";
          in
          {
            install =
              let
                developCmdArgumentPath =
                  "path:$PROJECT_PATH" + nixpkgs.lib.optionalString (meta.flakeDir != "") "/${meta.flakeDir}";
              in
              {
                type = "app";
                program = toString (
                  pkgs.writeShellScript "install" ''
                    PROJECT_PATH="''${1:-$(git rev-parse --show-toplevel)}"
                    mkdir -p ${meta.desktopPath}
                    cat > ${desktopEntry} <<DESKTOP
                    [Desktop Entry]
                    Name=${meta.ide.name} (${meta.name})
                    Exec=nix run ${developCmdArgumentPath} -- ${meta.ide.exec} $PROJECT_PATH
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
