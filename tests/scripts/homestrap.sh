# nixos-homestrap against a local repository and a key command that prints a test key
# shellcheck source=helpers.sh
source "$HELPERS"

repo=$TMPDIR/repo
git init -q "$repo"
echo "{ }" >"$repo/flake.nix"
git -C "$repo" add flake.nix
git -C "$repo" commit -qm init
ssh-keygen -q -t ed25519 -N "" -C test -f "$TMPDIR/userkey"

export NIXOS_FLAKE_DIR=$HOME/.config/nixos
export NIXOS_HOME_IDENTITY=.ssh/id_ed25519
homestrap() { bash "$SCRIPT" "$@"; }

expect_fail homestrap
expect_fail homestrap --no-reboot "$repo"

homestrap --no-reboot "$repo" "cat $TMPDIR/userkey" >first.out 2>&1
[ -f "$NIXOS_FLAKE_DIR/flake.nix" ] || fail "repository cloned to the flake checkout"
assert_eq "$(cat "$HOME/.ssh/id_ed25519")" "$(cat "$TMPDIR/userkey")" "key placed"
assert_mode "$HOME/.ssh" 700
assert_mode "$HOME/.ssh/id_ed25519" 600
assert_mode "$HOME/.ssh/id_ed25519.pub" 644
assert_eq "$(cat "$HOME/.ssh/id_ed25519.pub")" "$(ssh-keygen -y -f "$TMPDIR/userkey")" "public key derived"

# a second run keeps both and does not even run the key command
homestrap --no-reboot "$repo" "false" >second.out 2>&1
assert_contains second.out "exists, not cloning" "checkout kept"
assert_contains second.out "exists, not replacing it" "key kept"
assert_eq "$(cat "$HOME/.ssh/id_ed25519")" "$(cat "$TMPDIR/userkey")" "key unchanged"

# a failing key command stops before writing a key
rm -rf "$HOME/.ssh"
expect_fail homestrap --no-reboot "$repo" "false"
[ ! -e "$HOME/.ssh/id_ed25519" ] || fail "no key written when the key command fails"

echo "nixos-homestrap: all passed"
