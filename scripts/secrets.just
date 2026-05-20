# generate and print public key, and private key if needed, for the current user
user:
  #!/usr/bin/env bash
  set -euo pipefail
  key_path="$HOME/.ssh/id_ed25519"
  if [ ! -f "$key_path" ]; then
    ssh-keygen -t ed25519 -N "" -f "$key_path" -C "$USER@$(hostname)"
  fi
  echo "$(ssh-to-age < "$key_path.pub")"

# print public key for the current host
host:
  #!/usr/bin/env bash
  set -euo pipefail
  cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age

# sync hosts and users secrets with the config in .sop.yaml
update:
  #!/usr/bin/env bash
  set -euo pipefail
  find ../secrets -name '*.yaml' -exec sops updatekeys -y {} \;

new:
  #!/usr/bin/env bash
  set -euo pipefail
  keydir=$(mktemp -d)
  chmod 700 "$keydir"
  ssh-keygen -t ed25519 -N "" -f "$keydir/host_key" -C "host@env" >/dev/null
  ssh-keygen -t ed25519 -N "" -f "$keydir/user_key" -C "user@env" >/dev/null
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
