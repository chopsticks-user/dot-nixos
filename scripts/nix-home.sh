#!/usr/bin/env bash
set -euo pipefail

#flake_dir="$(jq -r ".directories.nixos" meta.json | sed "s|\$HOME|$HOME|")"