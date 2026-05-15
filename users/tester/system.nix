# this file belongs to nixosConfigurations
{
  pkgs,
  constants,
  ...
}:
{
  users.users.tester = {
    isNormalUser = true;
    description = "Tester";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };
}
