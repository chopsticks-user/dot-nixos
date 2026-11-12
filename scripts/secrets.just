# the machine directory these recipes operate on, relative to scripts/
machine := "../examples/andromeda"
host_attr := "..#nixosConfigurations.$(hostname).config"

user arg="edit":
  #!/usr/bin/env bash
  set -euo pipefail
  key_path="$HOME/$(nix eval --raw "{{host_attr}}.machine.directories.home.identity")"
  case "{{arg}}" in
    "public")
      ssh-to-age < "$key_path.pub";;
    "private")
      ssh-to-age -private-key -i $key_path;;
    "edit")
      sops "{{machine}}/users/$(whoami)/secrets.yaml";;
    *)
      echo "error: unknown argument '{{arg}}'" >&2 && exit 1;;
  esac

host arg="edit":
  #!/usr/bin/env bash
  set -euo pipefail
  key_path="$(nix eval --raw "{{host_attr}}.machine.directories.identity")"
  private_key_cmd="sudo ssh-to-age -private-key -i $key_path"
  case "{{arg}}" in
    "public")
      ssh-to-age < "$key_path.pub";;
    "private")
      $private_key_cmd;;
    "edit")
      SOPS_AGE_KEY_CMD=$private_key_cmd sops "{{machine}}/secrets.yaml";;
    *)
      echo "error: unknown argument '{{arg}}'" >&2 && exit 1;;
  esac

update:
  #!/usr/bin/env bash
  set -euo pipefail
  # todo: update host then update each user managed by host
#  find ../secrets -name '*.yaml' -exec sops updatekeys -y {} \;

backup out_path="../secrets/$(hostname).tar.gz":
  #!/usr/bin/env bash
  set -euo pipefail
  user_key_path_rel="$(nix eval --raw "{{host_attr}}.machine.directories.home.identity")"
  user_args=()
  while read -r username; do
    user_args+=( --transform="s|^home/$username/$user_key_path_rel|$username.key|" "/home/$username/$user_key_path_rel" )
  done < <(nix eval --json "{{host_attr}}.home-manager.users" --apply builtins.attrNames | jq -r ".[]")
  host_key_path="$(nix eval --raw "{{host_attr}}.machine.directories.identity")"
  sudo tar -czvf "{{out_path}}" \
    --transform="s|^etc/ssh/ssh_host_ed25519_key$|root.key|" \
    $host_key_path "${user_args[@]}"
  sudo chmod 644 "{{out_path}}"

new host user:
  #!/usr/bin/env bash
  set -euo pipefail
  if [ ! -d "{{machine}}/users/{{user}}" ]; then
    echo "error: {{machine}}/users/{{user}} does not exist" >&2
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
