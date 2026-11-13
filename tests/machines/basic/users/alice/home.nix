# account fields, a module with a system half (ssh), zsh, a plain git identity, and a package that
# only exists through the machine's overlays, and an unfree package she allows herself
{ pkgs, ... }:
{
  home.packages = [
    pkgs.greeting
    pkgs.unrar
  ];
  user = {
    description = "Alice";
    allowUnfree = [ "unrar" ];
    groups = [
      "wheel"
      "video"
    ];
  };
  modules = {
    zsh.enable = true;
    ssh.enable = true;
    git = {
      enable = true;
      user = {
        name = "Alice";
        email = "alice@example.com";
      };
    };
  };
}
