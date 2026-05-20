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
      just
      openssh
      jq
      git
      vim

      (pkgs.writeShellApplication {
        name = "nixos-bootstrap";
        runtimeInputs = [
          git
          just
          openssh
          jq
        ];
        text = builtins.readFile ../scripts/bootstrap.sh;
      })
    ];
  };
}
