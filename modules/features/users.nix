{ self, inputs, ... }: {
  flake.homeModules.frost = { pkgs, ... }: {
    imports = [ ../../users/frost/home.nix ];
  };
}
