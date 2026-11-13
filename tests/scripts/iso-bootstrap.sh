# the ISO's automatic bootstrap, built with hostile values: every value has to reach nixos-bootstrap
# and, through nixos-enter and su -c, nixos-homestrap exactly as given
# shellcheck disable=SC2016 # fake commands are literal scripts, expanded when they run
# shellcheck source=helpers.sh
source "$HELPERS"

export LOG_DIR=$TMPDIR/log
mkdir -p "$LOG_DIR"
fake sudo 'exec "$@"'
fake nixos-enter 'while [ "$1" != "--" ]; do shift; done; shift; exec "$@"'
# a login shell interprets -c; bash and zsh parse the quoting printf %q produces the same way
fake su 'exec bash -c "$4"'
fake nixos-homestrap 'printf "%s\n" "$@" >"$LOG_DIR/nixos-homestrap"'
fake reboot 'touch "$LOG_DIR/reboot"'

echo n | "$ISO_BOOTSTRAP" >run.out 2>&1 || fail "bootstrap failed:"$'\n'"$(cat run.out)"

assert_eq "$(cat "$LOG_DIR/nixos-bootstrap")" "--no-reboot"$'\n'"$REPO"$'\n'"$HOST"$'\n'"$HOST_KEY_CMD" "nixos-bootstrap arguments"
assert_eq "$(cat "$LOG_DIR/nixos-homestrap")" "--no-reboot"$'\n'"$REPO"$'\n'"$USER_KEY_CMD" "nixos-homestrap arguments"
[ ! -e "$LOG_DIR/reboot" ] || fail "rebooted although declined"

echo "iso bootstrap: all passed"
