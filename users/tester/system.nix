# this file belongs to nixosConfigurations
{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    "users/tester/password" = {
      neededForUsers = true;
      sopsFile = ../../secrets/users/tester.yaml;
      key = "password";
    };
  };

  users.users.tester = {
    isNormalUser = true;
    description = "Tester";
    hashedPasswordFile = config.sops.secrets."users/tester/password".path;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };
}
