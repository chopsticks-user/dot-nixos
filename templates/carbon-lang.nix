{
  description = "Carbon Language: An experimental successor to C++";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        meta = {name = "carbon-lang";};
        pkgs = import nixpkgs {inherit system;};
        llvmPkgs = pkgs.llvmPackages_latest;
        userBazelrc = pkgs.writeText "user.bazelrc" ''
          build --linkopt=-L${llvmPkgs.libunwind}/lib
          build --host_linkopt=-L${llvmPkgs.libunwind}/lib
          build --copt=-Wno-error=unused-command-line-argument
          build --cxxopt=-Wno-error=unused-command-line-argument
          build --host_copt=-Wno-error=unused-command-line-argument
          build --host_cxxopt=-Wno-error=unused-command-line-argument
        '';
      in {
        devShells.default =
          (pkgs.buildFHSEnv {
            name = "carbon-dev";
            targetPkgs = p:
              (with p; [
                bazelisk
                pre-commit
                python3
              ])
              ++ (with llvmPkgs; [
                clang
                lld
                lldb
                clang-tools
                llvm
              ])
              ++ (with pkgs; [
                zlib
                zstd
              ]);
            runScript = "zsh";
            profile = ''
              export CC=${llvmPkgs.libcxxClang}/bin/clang
              export CXX=${llvmPkgs.libcxxClang}/bin/clang++

              install -m 644 ${userBazelrc} "$PWD/user.bazelrc"
            '';
          }).env;

        apps = {
          install = {
            type = "app";
            program = toString (pkgs.writeShellScript "install" ''
              PROJECT_PATH="''${1:-$(git rev-parse --show-toplevel)}"
              mkdir -p ~/.local/share/applications
              cat > ~/.local/share/applications/clion-${meta.name}.desktop << DESKTOP
              [Desktop Entry]
              Name=CLion (${meta.name})
              Exec=nix develop $PROJECT_PATH -c clion $PROJECT_PATH
              Icon=clion
              Type=Application
              Categories=Development;
              DESKTOP
            '');
          };
          uninstall = {
            type = "app";
            program = toString (pkgs.writeShellScript "uninstall" ''
              rm -f ~/.local/share/applications/clion-${meta.name}.desktop
            '');
          };
        };
      }
    );
}
