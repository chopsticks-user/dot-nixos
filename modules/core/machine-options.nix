# machine-wide settings, set in system.nix
{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.machine.directories = {
    nixos = mkOption {
      type = types.str;
      default = "$HOME/.config/nixos";
      description = "Where the flake is checked out on the machine";
    };
    identity = mkOption {
      type = types.str;
      default = "/etc/ssh/ssh_host_ed25519_key";
      description = "Host SSH key, also the sops age identity";
    };
    home = mkOption {
      type = types.attrsOf types.str;
      description = "Well-known home directories, relative to each user's home";
      default = {
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
    };
  };
}
