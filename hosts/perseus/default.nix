{ self, inputs, config, ... }: {
  flake.nixosConfigurations.perseus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.perseus
    ];
  };
}
