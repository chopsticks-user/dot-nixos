# this file belongs to nixosConfigurations
{ username, ... }:
{
  environment.persistence."/persist".users.${username} = {
    directories = [
      "boxes"
      "documents"
      "downloads"
      "media"
      "projects"
      ".mozilla"
      ".doppler"
      ".claude"
      ".xdg-ignore"
      {
        directory = ".gnupg";
        mode = "0700";
      }
      {
        directory = ".ssh";
        mode = "0700";
      }
      {
        directory = ".nixops";
        mode = "0700";
      }

      # .config
      "nixos"
      "JetBrains"
      "discord"
      "gh"
      "dconf"
      "sops-nix"

      # .local/share
      ".local/share/JetBrains"
      ".local/share/Steam"
      ".local/share/zoxide"
      ".local/share/mpd"
      ".local/share/superfile"
      ".local/share/zed"
      ".local/share/hyprland"
      ".local/share/applications"
      ".local/share/icons"
      ".local/share/nvf"
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }

      # .local/state
      ".local/state/wireplumber"
      ".local/state/gh"

      # .cache
      "JetBrains"
      "nix"
      "mozilla"
      "zed"
    ];
    files = [
      ".zsh_history"
      ".bash_history"
      ".claude.json"
    ];
  };
}
