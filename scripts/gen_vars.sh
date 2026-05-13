#!/usr/bin/env bash

trap 'echo "error on line $LINENO, exiting..."; exit 1' ERR

users=( users/*/ )
users=( "${users[@]#users/}" )
users=( "${users[@]%/}" )
for user in "${users[@]}"; do
  doppler secrets --config "$user" download --no-file --format json | \
    jq '
      with_entries(select(.key | startswith("DOPPLER") | not))
      | reduce to_entries[] as $item (
          {};
          setpath(
            ($item.key | ascii_downcase | split("_"));
            $item.value
          )
        )
    ' | jq -s add > ./variables/"$user".json
done

nix hash path ./variables > ./variables/hash
nix store add ./variables
