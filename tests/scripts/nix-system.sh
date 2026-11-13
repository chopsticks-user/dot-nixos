# nix-system with nixos-rebuild, nvd, nix and sudo recording what they are asked to do
# shellcheck disable=SC2016 # fake commands are literal scripts, expanded when they run
# shellcheck source=helpers.sh
source "$HELPERS"

log=$TMPDIR/log
export LOG=$log
fake hostname 'echo testhost'
fake sudo 'echo "sudo $*" >>"$LOG"; exec "$@"'
fake nixos-rebuild 'echo "nixos-rebuild $*" >>"$LOG"; [ "$1" = build ] && echo /nix/store/fake-system; true'
fake nvd 'echo "nvd $*" >>"$LOG"'
fake nix 'echo "nix $*" >>"$LOG"'
export NIXOS_FLAKE_DIR=/flake
system() {
  : >"$log"
  bash "$SCRIPT" "$@"
}

system build
assert_contains "$log" "nixos-rebuild build --flake /flake#testhost" "build uses the machine flake"
assert_contains "$log" "nvd diff /run/current-system /nix/store/fake-system" "package diff"
assert_contains "$log" "nix store diff-closures /run/current-system /nix/store/fake-system" "closure diff"

echo n | system switch >/dev/null
assert_not_contains "$log" "switch" "declined switch does nothing"

echo y | system switch >/dev/null
assert_contains "$log" "sudo nixos-rebuild switch --flake /flake#testhost" "confirmed switch"

system info
assert_contains "$log" "nixos-rebuild list-generations" "info lists generations"

system boot --upgrade
assert_contains "$log" "nixos-rebuild boot --upgrade --flake /flake#testhost" "other actions get the flake"

echo "nix-system: all passed"
