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
        fhs = pkgs.buildFHSEnv {
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
              (p.runCommand "bazel" {} ''
                mkdir -p $out/bin
                ln -s ${p.bazelisk}/bin/bazelisk $out/bin/bazel
              '')
            ]);
          runScript = pkgs.writeShellScript "${meta.name}-fhs" ''
            alias bazel=bazelisk
            if [ $# -eq 0 ]; then exec zsh; else exec "$@"; fi
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
      }
    );
}
