# generate and print public key, and private key if needed, for the current user
user:
  #!/usr/bin/env bash
  set -euo pipefail
  age_path="$HOME/.config/sops/age"
  key_path="$HOME/.ssh/id_ed25519"
  if [ ! -f "$key_path" ]; then
    ssh-keygen -t ed25519 -N "" -f "$key_path" -C "$USER@$(hostname)"
  fi
  mkdir -p "$age_path"
  pubkey="$(ssh-to-age < "$key_path.pub")"
  {
    echo "# created: $(date -Iseconds)"
    echo "# public key: $pubkey"
    ssh-to-age -private-key -i "$key_path"
  } > "$age_path/keys.txt"
  echo "$pubkey"

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
