# belongs to nixosConfigurations
# todo: move to hosts
{ pkgs, constants, ... }: {
  # constants doesn't have .username here; username must be hardcoded
  users.users.frost = {
    isNormalUser = true;
    description = "Frost";
    initialPassword = constants.default-password;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
}
