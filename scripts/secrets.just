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
