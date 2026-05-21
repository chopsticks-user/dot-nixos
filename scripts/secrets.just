user arg="edit":
  #!/usr/bin/env bash
  set -euo pipefail
  key_path="$HOME/$(jq -r ".directories.home.identity" ../meta.json)"
  case "{{arg}}" in
    "public")
      ssh-to-age < "$key_path.pub";;
    "private")
      ssh-to-age -private-key -i $key_path;;
    "edit")
      sops ../secrets/users/$(whoami).yaml;;
    *)
      echo "error: unknown argument '{{arg}}'" >&2 && exit 1;;
  esac

host arg="edit":
  #!/usr/bin/env bash
  set -euo pipefail
  key_path="$(jq -r ".directories.system.identity" ../meta.json)"
  private_key_cmd="sudo ssh-to-age -private-key -i $key_path"
  case "{{arg}}" in
    "public")
      ssh-to-age < "$key_path.pub";;
    "private")
      $private_key_cmd;;
    "edit")
      SOPS_AGE_KEY_CMD=$private_key_cmd sops ../secrets/hosts/$(hostname).yaml;;
    *)
      echo "error: unknown argument '{{arg}}'" >&2 && exit 1;;
  esac

update:
  #!/usr/bin/env bash
  set -euo pipefail
  # todo: update host then update each user managed by host
#  find ../secrets -name '*.yaml' -exec sops updatekeys -y {} \;

new host user:
  #!/usr/bin/env bash
  set -euo pipefail
  if ! jq -e --arg host "{{host}}" '.hosts[$host]' ../meta.json >/dev/null; then
    echo "error: host '{{host}}' not found" >&2
    exit 1
  fi
  if ! jq -e --arg host "{{host}}" --arg username "{{user}}" '.hosts[$host].usernames | index($username)' ../meta.json >/dev/null; then
    echo "error: '{{user}}' not found in hosts.{{host}}.usernames" >&2
    exit 1
  fi
  keydir=$(mktemp -d)
  chmod 700 "$keydir"
  ssh-keygen -t ed25519 -N "" -f "$keydir/host_key" -C "root@{{host}}" >/dev/null
  ssh-keygen -t ed25519 -N "" -f "$keydir/user_key" -C "{{user}}@{{host}}" >/dev/null
  { ssh-to-age -private-key -i "$keydir/host_key"
    ssh-to-age -private-key -i "$keydir/user_key"; } > "$keydir/age_identities.txt"
  chmod 600 "$keydir/age_identities.txt"
  echo "host_key.pub: $(ssh-to-age < "$keydir/host_key.pub")"
  echo "user_key.pub: $(ssh-to-age < "$keydir/user_key.pub")"
  unset SOPS_AGE_SSH_PRIVATE_KEY_FILE SOPS_AGE_KEY SOPS_AGE_KEY_CMD SOPS_AGE_SSH_PRIVATE_KEY_CMD
  export SOPS_AGE_KEY_FILE="$keydir/age_identities.txt"
  export keydir=$keydir
  trap '[ -n "$keydir" ] && rm -rf "$keydir"' EXIT
  cd "{{invocation_directory()}}"
  $SHELL
