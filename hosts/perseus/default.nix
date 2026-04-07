{ self, inputs, config, ... }: {
  flake.nixosConfigurations.perseus = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      constants = config.flake.constants // {
        state-version = "26.05";
        hostname = "perseus";
      };
    };
    modules = [
      self.nixosModules.perseus
    ];
  };
}
