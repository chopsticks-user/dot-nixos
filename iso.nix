{modulesPath, ...}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  environment.etc."scripts" = {
    source = ./scripts;
    mode = "0755";
  };
}
