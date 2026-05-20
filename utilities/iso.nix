{
  modulesPath,
  inputs,
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
    ];

    etc = {
      "nixos".source = inputs.self;
    };
  };
}
