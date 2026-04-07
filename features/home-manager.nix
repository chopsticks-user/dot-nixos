{ self, inputs, ... }: {
  flake.nixosModules.feature-home-manager = { constants, pkgs, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit self inputs constants; };
      users = builtins.mapAttrs
        (name: _: import "${self.outPath}/users/${name}")
	(builtins.readDir "${self.outPath}/users");
    };
  };
}
