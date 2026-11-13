# sourced by every script test: assertions that stop the test with a readable message, and fake
# commands that shadow real ones on PATH
set -euo pipefail

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  [ "$1" = "$2" ] || fail "$3"$'\n'"  expected: $2"$'\n'"  actual:   $1"
}

assert_contains() {
  grep -qF -- "$2" "$1" || fail "$3: '$2' not found in $1:"$'\n'"$(cat "$1")"
}

assert_not_contains() {
  if grep -qF -- "$2" "$1"; then
    fail "$3: '$2' unexpectedly found in $1"
  fi
}

assert_mode() {
  assert_eq "$(stat -c %a "$1")" "$2" "mode of $1"
}

# expect_fail <command>...: the command has to exit with an error
expect_fail() {
  if "$@" >"$TMPDIR/expect_fail.out" 2>&1; then
    fail "expected to fail: $*"$'\n'"$(cat "$TMPDIR/expect_fail.out")"
  fi
}

fakes=$TMPDIR/fakes
mkdir -p "$fakes"
export PATH="$fakes:$PATH"

# fake <name> <body>: a bash script on PATH ahead of the real command
fake() {
  printf '#!%s\n%s\n' "$(command -v bash)" "$2" >"$fakes/$1"
  chmod +x "$fakes/$1"
}

export HOME=$TMPDIR/home
mkdir -p "$HOME"
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
