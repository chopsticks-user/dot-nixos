{ self, inputs, ... }: {
  flake.nixosModules.laptopHardware = { config, pkgs, lib, ... }: {
    imports = [ ./_hardware.nix ];
  };
}
