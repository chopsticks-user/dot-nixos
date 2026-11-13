# runs the scripts in scripts/ for real in the build sandbox, each with its test in scripts/ and the
# outside world (sudo, nixos-rebuild, disko, nixos-install, ...) faked on PATH
{ pkgs }:
let
  run =
    name: env:
    pkgs.runCommand "test-script-${name}"
      (
        {
          nativeBuildInputs = with pkgs; [
            git
            openssh
            sops
            ssh-to-age
          ];
          HELPERS = ./scripts/helpers.sh;
        }
        // env
      )
      ''
        cd "$TMPDIR"
        bash ${./scripts + "/${name}.sh"}
        touch $out
      '';

  # quotes, spaces, $ and backticks that must survive two rounds of shell quoting
  iso = {
    REPO = "https://example.com/me/my machine.git";
    HOST = "my-host";
    ISO_USER = "tester";
    HOST_KEY_CMD = "ssh me@dev 'tar -xOzf \"keys/a b.tar.gz\" root.key' && echo \"$HOME\" `id -u`";
    USER_KEY_CMD = "printf '%s' \"it's\" | cat; echo $(( 1 + 1 ))";
  };
  isoBootstrap = pkgs.callPackage ../lib/iso-bootstrap.nix {
    curl = pkgs.writeShellScriptBin "curl" "true";
    nixos-bootstrap = pkgs.writeShellScriptBin "nixos-bootstrap" ''
      printf '%s\n' "$@" >"$LOG_DIR/nixos-bootstrap"
    '';
    repo = iso.REPO;
    host = iso.HOST;
    user = iso.ISO_USER;
    hostKeyCmd = iso.HOST_KEY_CMD;
    userKeyCmd = iso.USER_KEY_CMD;
  };
in
{
  secrets = run "secrets" { SCRIPT = ../scripts/secrets.sh; };
  homestrap = run "homestrap" { SCRIPT = ../scripts/homestrap.sh; };
  nix-system = run "nix-system" { SCRIPT = ../scripts/nix-system.sh; };
  bootstrap = run "bootstrap" { SCRIPT = ../scripts/bootstrap.sh; };
  iso-bootstrap = run "iso-bootstrap" (iso // { ISO_BOOTSTRAP = "${isoBootstrap}/bin/bootstrap"; });
}
