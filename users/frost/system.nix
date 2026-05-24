# this file belongs to nixosConfigurations
{ ... }:
{
  systemProfiles = {
    ssh.enable = true;
    hyprland.enable = true;
    virtualization.enable = true;
    gaming.enable = true;
  };
}
