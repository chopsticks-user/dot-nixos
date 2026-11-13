#!/usr/bin/env bash
# set by the framework: NIXOS_FLAKE_DIR, NIXOS_HOME_IDENTITY (relative to home),
# NIXOS_HOST_IDENTITY (absolute), NIXOS_USERS (space separated)
set -euo pipefail

usage() {
  cat <<'EOF'
nixos-secrets - this machine's sops secrets and SSH identities

Usage:
  nixos-secrets host [edit|public|private] [<machine-dir>]
  nixos-secrets user [edit|public|private] [<machine-dir>]
  nixos-secrets update [<machine-dir>]
  nixos-secrets new <host> <user>...
  nixos-secrets backup

  host     the machine's secrets.yaml, decrypted with the host key
  user     users/<you>/secrets.yaml, decrypted with your key
  edit     open the file in sops, creating it from .sops.yaml if missing (default)
  public   print the age public key
  private  print the age private key
  update   re-encrypt both files to the recipients currently in .sops.yaml
  new      generate a host key and user keys for a machine that does not exist
           yet, into ./<host>.tar.gz, and print their age public keys
  backup   archive this machine's host key and every user's key into
           ./<hostname>.tar.gz

<machine-dir> defaults to $NIXOS_FLAKE_DIR. Archives are never overwritten.
EOF
}

host_key=$NIXOS_HOST_IDENTITY
user_key=$HOME/$NIXOS_HOME_IDENTITY
# sops runs these itself to get the age identity
host_key_cmd="sudo ssh-to-age -private-key -i $host_key"
user_key_cmd="ssh-to-age -private-key -i $user_key"

# run_sops <key command> <file> <sops arguments>...; sops looks for .sops.yaml from the working
# directory upwards, so it runs next to the file
run_sops() {
  local key_cmd="$1" file="$2"
  shift 2
  (cd "$(dirname "$file")" && SOPS_AGE_KEY_CMD="$key_cmd" sops "$@" "$file")
}

# an archive may hold the only copy of a private key, so an existing one is never replaced
archive_path() {
  local path="$PWD/$1.tar.gz"
  if [ -e "$path" ]; then
    echo "error: $path already exists" >&2
    exit 1
  fi
  echo "$path"
}

command=${1:-}
[ $# -gt 0 ] && shift

case "$command" in
  host | user)
    action=${1:-edit}
    dir=$(realpath "${2:-$NIXOS_FLAKE_DIR}")
    if [ "$command" = host ]; then
      key=$host_key
      key_cmd=$host_key_cmd
      file=$dir/secrets.yaml
    else
      key=$user_key
      key_cmd=$user_key_cmd
      file=$dir/users/$(whoami)/secrets.yaml
    fi
    case "$action" in
      edit)
        mkdir -p "$(dirname "$file")"
        run_sops "$key_cmd" "$file"
        ;;
      public) ssh-to-age <"$key.pub" ;;
      private) bash -c "$key_cmd" ;;
      *)
        usage >&2
        exit 1
        ;;
    esac
    ;;

  update)
    dir=$(realpath "${1:-$NIXOS_FLAKE_DIR}")
    run_sops "$host_key_cmd" "$dir/secrets.yaml" updatekeys -y
    if [ -f "$dir/users/$(whoami)/secrets.yaml" ]; then
      run_sops "$user_key_cmd" "$dir/users/$(whoami)/secrets.yaml" updatekeys -y
    fi
    ;;

  new)
    if [ $# -lt 2 ]; then
      usage >&2
      exit 1
    fi
    host=$1
    shift
    for user in "$@"; do
      # root.key is the host key in the archive
      if [ "$user" = root ]; then
        echo "error: root is not a user of a machine" >&2
        exit 1
      fi
    done
    out=$(archive_path "$host")
    keydir=$(mktemp -d)
    trap 'rm -rf "$keydir"' EXIT
    ssh-keygen -q -t ed25519 -N "" -C "root@$host" -f "$keydir/root.key"
    for user in "$@"; do
      ssh-keygen -q -t ed25519 -N "" -C "$user@$host" -f "$keydir/$user.key"
    done
    (umask 077 && tar -czf "$out" -C "$keydir" root.key "${@/%/.key}")
    echo "Private keys: $out"
    echo "Age public keys for .sops.yaml:"
    echo "  host $host: $(ssh-to-age <"$keydir/root.key.pub")"
    for user in "$@"; do
      echo "  user $user: $(ssh-to-age <"$keydir/$user.key.pub")"
    done
    ;;

  backup)
    out=$(archive_path "$(hostname)")
    keydir=$(mktemp -d)
    trap 'rm -rf "$keydir"' EXIT
    sudo install -m 600 -o "$(id -u)" -g "$(id -g)" "$host_key" "$keydir/root.key"
    read -ra users <<<"$NIXOS_USERS"
    for user in "${users[@]}"; do
      key="$(getent passwd "$user" | cut -d: -f6)/$NIXOS_HOME_IDENTITY"
      if sudo test -f "$key"; then
        sudo install -m 600 -o "$(id -u)" -g "$(id -g)" "$key" "$keydir/$user.key"
      else
        echo "warning: $user has no key at $key, skipped" >&2
      fi
    done
    (umask 077 && cd "$keydir" && tar -czf "$out" -- *.key)
    echo "Private keys: $out"
    ;;

  -h | --help | help)
    usage
    ;;

  *)
    usage >&2
    exit 1
    ;;
esac
