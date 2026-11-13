# renders docs/options.md from a machine's option declarations; the flake checks the committed file
# against it and `just docs` rewrites it
{
  lib,
  pkgs,
  machine,
}:
let
  json =
    options:
    (pkgs.nixosOptionsDoc {
      inherit options;
      transformOptions =
        opt:
        opt
        // {
          # store paths would change the file on every edit; the module table already lists every enable flag
          declarations = [ ];
          visible = opt.visible && !(lib.hasPrefix "modules." opt.name && lib.hasSuffix ".enable" opt.name);
        };
    }).optionsJSON
    + "/share/doc/nixos/options.json";

  homeOptions = machine.options.home-manager.users.type.nestedTypes.elemType.getSubOptions [ ];
in
pkgs.runCommand "options.md" { nativeBuildInputs = [ pkgs.jq ]; } ''
  render() {
    jq -r '
      def default:
        if .default == null then ""
        elif .default._type == "literalMD" then "\n\n  Default: \(.default.text)"
        elif (.default.text | contains("\n")) then "\n\n  Default:\n\n  ```nix\n\(.default.text | split("\n") | map("  " + .) | join("\n"))\n  ```"
        else "\n\n  Default: `\(.default.text)`"
        end;
      to_entries | sort_by(.key)[] | .value as $o
      | "- `\(.key)` (\($o.type)): \($o.description | gsub("\n"; " "))\($o | default)\n"
    ' "$1"
  }
  {
    cat <<'EOF'
  # Options

  Generated from the option declarations by `just docs`; do not edit by hand.
  `nix flake check` fails when this file is out of date. Module `enable` flags
  are listed in the module table of [guide.md](guide.md#76-modules).

  ## NixOS options

  Set in `system/`.

  EOF
    render ${json { inherit (machine.options) machine modules; }}
    cat <<'EOF'
  ## Home Manager options

  Set in `users/<name>/home.nix`.

  EOF
    render ${json { inherit (homeOptions) user modules; }}
  } > $out
''
