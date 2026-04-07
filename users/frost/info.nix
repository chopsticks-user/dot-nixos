{ pkgs, ... }: {
  users.users.frost = {
    isNormalUser = true;
    description = "Frost";
    initialPassword = "password";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
}
