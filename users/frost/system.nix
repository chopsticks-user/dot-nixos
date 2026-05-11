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
    initialPassword = constants.default-password;
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
    distrobox.enable = true;
  };
}
