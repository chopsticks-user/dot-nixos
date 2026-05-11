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
        meta = {
          name = "carbon-lang";
          ide = {
            name = "CLion";
            exec = "clion";
            icon = "clion";
          };
          flakeDir = "flake"; # edit as needed
        };
        pkgs = import nixpkgs {inherit system;};
        fhs = let
          llvmPkgs = pkgs.llvmPackages_latest;
          userBazelrc = pkgs.writeText "user.bazelrc" ''
            build --action_env=PATH
            build --action_env=NIX_CFLAGS_COMPILE
            build --action_env=NIX_LDFLAGS
            build --host_action_env=PATH
            build --host_action_env=NIX_CFLAGS_COMPILE
            build --host_action_env=NIX_LDFLAGS
            build --linkopt=-L${llvmPkgs.libunwind}/lib
            build --host_linkopt=-L${llvmPkgs.libunwind}/lib

            build --copt=-Wno-error=unused-command-line-argument
            build --cxxopt=-Wno-error=unused-command-line-argument
            build --host_copt=-Wno-error=unused-command-line-argument
            build --host_cxxopt=-Wno-error=unused-command-line-argument

            build:dev --spawn_strategy=local
            build:dev --disk_cache=~/.cache/bazel-disk-cache

            build:ci --spawn_strategy=sandboxed
            build:ci --sandbox_add_mount_pair=/nix/store
            build:ci --disk_cache=~/.cache/bazel-disk-cache
          '';
        in
          pkgs.buildFHSEnv {
            name = "${meta.name}-fhs";
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
                libcxx
              ])
              ++ (with pkgs; [
                zlib
                zstd
                stdenv.cc.libc.dev
                (p.runCommand "bazel" {} ''
                  mkdir -p $out/bin
                  ln -s ${p.bazelisk}/bin/bazelisk $out/bin/bazel
                '')
              ]);
            runScript = pkgs.writeShellScript "${meta.name}-fhs" ''
              if [ $# -eq 0 ]; then
                exec "$(getent passwd "$USER" | cut -d: -f7)"
              else
                exec "$@"
              fi
            '';
            profile = ''
              export CC=${llvmPkgs.libcxxClang}/bin/clang
              export CXX=${llvmPkgs.libcxxClang}/bin/clang++
              export PATH="${pkgs.bazelisk}/bin:$PATH"
              install -m 644 ${userBazelrc} "$(git rev-parse --show-toplevel)/user.bazelrc"
            '';
          };
      in {
        devShells.default = fhs.env;
        apps = let
          desktopEntry = "$HOME/.local/share/applications/${meta.ide.exec}-${meta.name}.desktop";
        in {
          default = {
            type = "app";
            program = "${fhs}/bin/${meta.name}-fhs";
          };
          install = let
            developCmdArgumentPath =
              "path:$PROJECT_PATH" + nixpkgs.lib.optionalString (meta.flakeDir != "") "/${meta.flakeDir}";
          in {
            type = "app";
            program = toString (
              pkgs.writeShellScript "install" ''
                PROJECT_PATH="''${1:-$(git rev-parse --show-toplevel)}"
                mkdir -p ~/.local/share/applications
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
            program = toString (pkgs.writeShellScript "uninstall" ''
              set -eu
              rm -rf \
                "$HOME/.cache/bazel" \
                "$HOME/.cache/bazelisk \
                "$HOME/.cache/bazel-disk-cache" \
                "$HOME/.cache/carbon-lang-build-cache"

              if repo="$(git rev-parse --show-toplevel 2>/dev/null)"; then
                rm -rf "$repo"/bazel-* "$repo/user.bazelrc"
              fi

              rm -f ${desktopEntry}
            '');
          };
        };
      }
    );
}
