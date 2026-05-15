# this file belongs to nixosConfigurations
{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    "users/frost/password" = {
      neededForUsers = true;
      sopsFile = ../../secrets/users/frost.yaml;
      key = "password";
    };
  };

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

  features = {
    hyprland.enable = true;
    virtualization.enable = true;
    gaming.enable = true;
  };
}
