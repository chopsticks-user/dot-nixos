# nixos-secrets against real sops and keys; only sudo, whoami, hostname and getent are faked
# shellcheck disable=SC2016 # fake commands are literal scripts, expanded when they run
# shellcheck source=helpers.sh
source "$HELPERS"

fake sudo 'exec "$@"'
fake whoami 'echo alice'
fake hostname 'echo testhost'
fake getent "case \"\$2\" in alice) echo \"alice:x:1000:100::$HOME:/bin/sh\" ;; bob) echo \"bob:x:1001:100::$TMPDIR/bob:/bin/sh\" ;; esac"
secrets() { bash "$SCRIPT" "$@"; }

# baked into the installed command; the host key itself is created further down
machine=$TMPDIR/machine
export NIXOS_FLAKE_DIR=$machine
export NIXOS_HOME_IDENTITY=.ssh/id_ed25519
export NIXOS_HOST_IDENTITY=$TMPDIR/etc/host_key
export NIXOS_USERS="alice bob"

mkdir -p "$TMPDIR/work"
cd "$TMPDIR/work"

# usage
for args in "" "new onlyhost" "host bogus" "bogus"; do
  # shellcheck disable=SC2086 # split into arguments on purpose
  expect_fail secrets $args
  assert_contains "$TMPDIR/expect_fail.out" "Usage:" "usage for '$args'"
done

# new: archive with every key, mode 600, never overwritten, root rejected
secrets new myhost alice bob >new.out
assert_mode myhost.tar.gz 600
assert_eq "$(tar -tzf myhost.tar.gz | sort | tr '\n' ' ')" "alice.key bob.key root.key " "archive members"
assert_contains new.out "host myhost: age1" "host public key printed"
assert_contains new.out "user alice: age1" "alice public key printed"
assert_contains new.out "user bob: age1" "bob public key printed"
before=$(sha256sum myhost.tar.gz)
expect_fail secrets new myhost alice
assert_eq "$(sha256sum myhost.tar.gz)" "$before" "existing archive untouched"
expect_fail secrets new otherhost root
[ ! -e otherhost.tar.gz ] || fail "archive written despite rejected user"

# the machine: host key and alice's key from the archive, recipients in .sops.yaml
mkdir -p "$TMPDIR/etc" "$HOME/.ssh"
tar -xOzf myhost.tar.gz root.key >"$TMPDIR/etc/host_key"
tar -xOzf myhost.tar.gz alice.key >"$HOME/.ssh/id_ed25519"
chmod 600 "$TMPDIR/etc/host_key" "$HOME/.ssh/id_ed25519"
ssh-keygen -y -f "$TMPDIR/etc/host_key" >"$TMPDIR/etc/host_key.pub"
ssh-keygen -y -f "$HOME/.ssh/id_ed25519" >"$HOME/.ssh/id_ed25519.pub"
host_age=$(ssh-to-age <"$TMPDIR/etc/host_key.pub")
alice_age=$(ssh-to-age <"$HOME/.ssh/id_ed25519.pub")
tar -xOzf myhost.tar.gz bob.key >"$TMPDIR/bob.key"
chmod 600 "$TMPDIR/bob.key"
bob_age=$(ssh-keygen -y -f "$TMPDIR/bob.key" | ssh-to-age)

mkdir -p "$machine"
cat >"$machine/.sops.yaml" <<EOF
creation_rules:
  - path_regex: ^secrets\.yaml\$
    key_groups:
      - age: [ $host_age ]
  - path_regex: ^users/alice/secrets\.yaml\$
    key_groups:
      - age: [ $alice_age ]
EOF

# public and private keys
assert_eq "$(secrets host public)" "$host_age" "host public key"
assert_eq "$(secrets user public)" "$alice_age" "user public key"
secrets user private | grep -q '^AGE-SECRET-KEY-' || fail "user private key"

# edit creates the files from .sops.yaml, encrypted to the right key
writer=$TMPDIR/writer
printf '#!/bin/sh\nprintf "%%s\\n" "$CONTENT" >"$1"\n' >"$writer"
chmod +x "$writer"
export EDITOR=$writer
CONTENT="password: {root: hash}" secrets host edit
CONTENT="git: {name: Alice}" secrets user edit
assert_contains "$machine/secrets.yaml" "ENC[" "host file encrypted"
assert_contains "$machine/users/alice/secrets.yaml" "ENC[" "user file encrypted"
decrypt() { SOPS_AGE_KEY_CMD="ssh-to-age -private-key -i $2" sops -d "$1"; }
decrypt "$machine/secrets.yaml" "$TMPDIR/etc/host_key" | grep -q "root: hash" || fail "host file decrypts with the host key"
decrypt "$machine/users/alice/secrets.yaml" "$HOME/.ssh/id_ed25519" | grep -q "name: Alice" || fail "user file decrypts with alice's key"
expect_fail decrypt "$machine/users/alice/secrets.yaml" "$TMPDIR/etc/host_key"

# edit decrypts an existing file and writes the change back
CONTENT="git: {name: Alice B}" secrets user edit
decrypt "$machine/users/alice/secrets.yaml" "$HOME/.ssh/id_ed25519" | grep -q "name: Alice B" || fail "user file edited"

# a directory argument instead of the checkout
other=$TMPDIR/other
mkdir -p "$other"
cp "$machine/.sops.yaml" "$other/"
CONTENT="password: {root: other}" secrets host edit "$other"
decrypt "$other/secrets.yaml" "$TMPDIR/etc/host_key" | grep -q "root: other" || fail "machine directory argument"

# update re-encrypts to recipients added since
sed -i "s|age: \[ $alice_age \]|age: [ $alice_age, $bob_age ]|" "$machine/.sops.yaml"
secrets update
decrypt "$machine/users/alice/secrets.yaml" "$TMPDIR/bob.key" | grep -q "name: Alice B" || fail "update added bob as a recipient"

# backup: host key and every user that has a key, never overwritten
secrets backup 2>backup.err
assert_mode testhost.tar.gz 600
assert_eq "$(tar -tzf testhost.tar.gz | sort | tr '\n' ' ')" "alice.key root.key " "backup members"
assert_contains backup.err "bob has no key" "missing user key reported"
assert_eq "$(tar -xOzf testhost.tar.gz root.key)" "$(cat "$TMPDIR/etc/host_key")" "backed up host key"
expect_fail secrets backup

echo "nixos-secrets: all passed"
