# per-user settings, set in users/<name>/home.nix; peruser.nix reads the account fields
{
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.user = {
    description = mkOption {
      type = types.str;
      default = "";
    };
    groups = mkOption {
      type = types.listOf types.str;
      default = [
        "wheel"
        "networkmanager"
      ];
    };
    shell = mkOption {
      type = types.str;
      default = "zsh";
      description = "Attribute name in pkgs, also used as the login shell";
    };
    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Attribute name in pkgs";
    };
    theme = mkOption {
      type = types.enum [
        "dark"
        "light"
      ];
      default = "dark";
    };
    directories = mkOption {
      type = types.attrsOf types.str;
      default = lib.mapAttrs (
        _: path: "${config.home.homeDirectory}/${path}"
      ) osConfig.machine.directories.home;
      defaultText = "machine.directories.home resolved against home.homeDirectory";
      description = "Absolute paths of well-known home directories";
    };
  };
}
