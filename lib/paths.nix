{ lib, ... }:
{
  # drops duplicates and paths nested in another listed path, keeping order; impermanence rejects
  # overlapping entries
  outermostPaths =
    paths:
    let
      unique = lib.unique paths;
    in
    lib.filter (p: !lib.any (q: lib.hasPrefix "${q}/" p) unique) unique;
}
