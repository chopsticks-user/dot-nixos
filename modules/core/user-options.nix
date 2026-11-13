# per-user settings, set in users/<name>/home.nix; peruser.nix reads the account fields
{
  lib,
  config,
  osConfig,
  pkgs,
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
      type = types.package;
      default = pkgs.bashInteractive;
      defaultText = lib.literalExpression "pkgs.bashInteractive";
      description = "Login shell, also exported as SHELL; modules.zsh makes it zsh by default";
    };
    terminal = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Terminal emulator exported as TERMINAL; modules.hyprland makes it kitty by default";
    };
    allowUnfree = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Unfree package names this user installs; allowed machine-wide, because all users share the system's nixpkgs";
    };
    directories = mkOption {
      type = types.attrsOf types.str;
      description = "Absolute paths of well-known home directories, by default machine.directories.home resolved against home.homeDirectory; each can be overridden on its own";
    };
  };

  # one default per key, so overriding one directory keeps the others
  config.user.directories = lib.mapAttrs (
    _: path: lib.mkDefault "${config.home.homeDirectory}/${path}"
  ) osConfig.machine.directories.home;
}
