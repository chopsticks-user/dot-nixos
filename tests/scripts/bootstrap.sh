# nixos-bootstrap with nix, disko, nixos-install and the privileged steps recorded instead of run;
# the repository is real and the host key really lands under the mount point
# shellcheck disable=SC2016 # fake commands are literal scripts, expanded when they run
# shellcheck source=helpers.sh
source "$HELPERS"

log=$TMPDIR/log
export LOG=$log
repo=$TMPDIR/repo
git init -q "$repo"
echo "{ }" >"$repo/flake.nix"
git -C "$repo" add flake.nix
git -C "$repo" commit -qm init
ssh-keygen -q -t ed25519 -N "" -C root@myhost -f "$TMPDIR/hostkey"

# stands in for evaluating the cloned machine
export HOST_EXISTS=true KEY_PATH=/persist/etc/ssh/ssh_host_ed25519_key
fake nix '
case "$*" in
  *"eval --json"*"#nixosConfigurations --apply"*) echo "$HOST_EXISTS" ;;
  *"eval --raw"*"sshKeyPaths --apply builtins.head"*) echo "$KEY_PATH" ;;
  *" run "*) echo "disko $*" >>"$LOG" ;;
  *) echo "unexpected: nix $*" >&2; exit 1 ;;
esac'
fake sudo 'if [ "$1" = chown ]; then echo "sudo $*" >>"$LOG"; else exec "$@"; fi'
fake nixos-generate-config 'echo "nixos-generate-config $*" >>"$LOG"'
fake nixos-install 'echo "nixos-install $*" >>"$LOG"'

mnt=$TMPDIR/mnt
export NIXOS_BOOTSTRAP_MOUNT=$mnt
bootstrap() {
  : >"$log"
  bash "$SCRIPT" "$@"
}

expect_fail bootstrap
expect_fail bootstrap --no-reboot "$repo" myhost

bootstrap --no-reboot "$repo" myhost "cat $TMPDIR/hostkey" >run.out 2>&1
key=$mnt$KEY_PATH
assert_eq "$(cat "$key")" "$(cat "$TMPDIR/hostkey")" "host key written where sops reads it"
assert_mode "$key" 600
assert_mode "$key.pub" 644
assert_eq "$(cat "$key.pub")" "$(ssh-keygen -y -f "$TMPDIR/hostkey")" "public host key derived"
assert_contains "$log" "sudo chown root:root $key" "host key owned by root"
assert_contains "$log" "#myhost --mode destroy,format,mount --root-mountpoint $mnt" "disko formats and mounts the machine"
assert_contains "$log" "nixos-generate-config --no-filesystems --root $mnt" "reference hardware config"
assert_contains "$log" "#myhost --no-root-password --root $mnt" "installs the machine"

# without impermanence the key goes to /etc/ssh
KEY_PATH=/etc/ssh/ssh_host_ed25519_key
bootstrap --no-reboot "$repo" myhost "cat $TMPDIR/hostkey" >/dev/null 2>&1
[ -f "$mnt/etc/ssh/ssh_host_ed25519_key" ] || fail "host key under /etc/ssh without impermanence"

# a repository without the host stops before touching any disk
HOST_EXISTS=false
expect_fail bootstrap --no-reboot "$repo" otherhost "cat $TMPDIR/hostkey"
assert_contains "$TMPDIR/expect_fail.out" "has no nixosConfigurations.otherhost" "missing host reported"
assert_not_contains "$log" "disko" "no disk touched for a missing host"

echo "nixos-bootstrap: all passed"
