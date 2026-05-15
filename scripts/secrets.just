# generate and print public key, and private key if needed, for the current user
user:
  #!/usr/bin/env bash
  set -euo pipefail
  age_path="$HOME/.config/sops/age"
  mkdir -p "$age_path"
  if [ -f "$age_path" ]; then
    age-keygen -o "$age_path/keys.txt"
  else
    age-keygen -y "$age_path/keys.txt"
  fi

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
