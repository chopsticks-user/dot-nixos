# machine-wide settings, set in system.nix
{ lib, ... }:
let
  inherit (lib) mkOption types;

  homeDefaults = {
    identity = ".ssh/id_ed25519";
    cache = ".cache";
    config = ".config";
    data = ".local/share";
    state = ".local/state";
    bin = ".local/bin";
    documents = "documents";
    download = "downloads";
    projects = "projects";
    boxes = "boxes";
    media = "media";
    pictures = "media/images";
    music = "media/audio";
    videos = "media/videos";
    wallpapers = "media/images/wallpapers";
    screenshots = "media/images/screenshots";
    screencasts = "media/videos/screencasts";
    desktop = ".local/share/.xdg-ignore";
    templates = ".local/share/.xdg-ignore";
    publicShare = ".local/share/.xdg-ignore";
  };
in
{
  options.machine.directories = {
    nixos = mkOption {
      type = types.str;
      default = "$HOME/.config/nixos";
      description = "Where users check out the machine repository, used by the scripts and nh; `$HOME` is expanded at runtime";
    };
    identity = mkOption {
      type = types.str;
      default = "/etc/ssh/ssh_host_ed25519_key";
      description = "Host SSH key, also the age identity for host secrets";
    };
    home = mkOption {
      type = types.attrsOf types.str;
      defaultText = lib.literalExpression (lib.generators.toPretty { } homeDefaults);
      description = "Well-known home directories, relative to each user's home; each can be overridden on its own. The user key (`identity`) must be inside a directory of home, because that directory is persisted with mode 0700";
    };
  };

  # one default per key, so overriding one directory keeps the others
  config.machine.directories.home = lib.mapAttrs (_: lib.mkDefault) homeDefaults;
}
