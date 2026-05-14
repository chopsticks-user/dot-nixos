# this file belongs to nixosConfigurations
{
  config,
  pkgs,
  ...
}:
{
  users.users.frost = {
    isNormalUser = true;
    description = "Frost";
    hashedPasswordFile = config.sops.secrets."users/frost/password".path;
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
