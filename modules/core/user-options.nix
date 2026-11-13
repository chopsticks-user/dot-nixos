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
