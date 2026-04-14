{modulesPath, ...}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  environment.etc."nixos/bootstrap.sh" = {
    source = ./bootstrap.sh;
    mode = "0755";
  };

  environment.etc."nixos/install.sh" = {
    source = ./install.sh;
    mode = "0755";
  };
}
