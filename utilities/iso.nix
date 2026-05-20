{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.zfs.forceImportRoot = false;

  environment = {
    systemPackages = with pkgs; [
      git
      vim

      (pkgs.writeShellApplication {
        name = "nixos-bootstrap";
        runtimeInputs = [
          just
          openssh
          jq
        ];
        text = builtins.readFile ../scripts/bootstrap.sh;
      })
    ];
  };
}
