# this file belongs to nixosConfigurations
{
  pkgs,
  constants,
  ...
}:
{
  # constants doesn't have .username here; username must be hardcoded
  users.users.frost = {
    isNormalUser = true;
    description = "Frost";
    initialPassword = constants.defaultPassword;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  programs = {
    zsh.enable = true;
  };

  features = {
    hyprland.enable = true;
    virtualization.enable = true;
    gaming.enable = true;
  };
}
