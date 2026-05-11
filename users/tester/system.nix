# this file belongs to nixosConfigurations
{
  pkgs,
  constants,
  ...
}:
{
  programs.zsh.enable = true;

  # constants doesn't have .username here; username must be hardcoded
  users.users.tester = {
    isNormalUser = true;
    description = "Tester";
    initialPassword = constants.default-password;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };
}
