{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit self; };
      users = self.homeModules;
    };
  };
}
