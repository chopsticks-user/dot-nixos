{
  description = "andromeda: one machine, two users, built with dot-nixos";

  # outside this repository: url = "github:chopsticks-user/dot-nixos";
  inputs.dot-nixos.url = "path:../..";

  outputs = { dot-nixos, ... }: dot-nixos.lib.mkMachine ./.;
}
