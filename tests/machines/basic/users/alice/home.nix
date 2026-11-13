# account fields, a module with a system half (ssh), zsh, a plain git identity, and a package that
# only exists through the machine's overlays
{ pkgs, ... }:
{
  home.packages = [ pkgs.greeting ];
  user = {
    description = "Alice";
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
