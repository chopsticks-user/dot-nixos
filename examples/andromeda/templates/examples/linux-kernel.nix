{
  description = "The Linux Kernel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        meta = {
          name = "linux-kernel";
        };
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            gnumake
            binutils
            gcc
            flex
            bison
            rustup
            ncurses.dev
            pkg-config
            elfutils.dev
            bc
            openssl.dev
            qemu_kvm
          ];

          shellHook = "";
        };
        apps = {
          install = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "install" ''
                PROJECT_PATH="''${1:-$(git rev-parse --show-toplevel)}"
                mkdir -p ~/.local/share/applications
                cat > ~/.local/share/applications/clion-${meta.name}.desktop << DESKTOP
                [Desktop Entry]
                Name=CLion (${meta.name})
                Exec=nix develop path:$PROJECT_PATH/flake -c clion $PROJECT_PATH
                Icon=clion
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
                rm -f ~/.local/share/applications/clion-${meta.name}.desktop
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
