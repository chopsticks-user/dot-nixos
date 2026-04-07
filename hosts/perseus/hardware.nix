{ self, inputs, ... }: {
  flake.nixosModules.perseus-hardware = { config, pkgs, lib, ... }: {
    imports = [ ./_hardware.nix ];
  };
}
