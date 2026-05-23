{
  directories = [
    "boxes"
    "documents"
    "downloads"
    "media"
    "projects"
    ".xdg-ignore"
    ".mozilla"
    ".doppler"
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
    ".config/nixos"
    ".config/hypr"
    ".config/noctalia"
    ".config/zsh"
    ".config/JetBrains"
    ".config/discord"
    ".config/gh"
    ".config/dconf"
    ".config/sops-nix"

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
    ".local/state/nix"
    ".local/state/home-manager"

    # .cache
    ".cache/JetBrains"
    ".cache/nix"
    ".cache/mozilla"
    ".cache/zed"
    ".cache/noctalia"
  ];

  files = [
    ".zsh_history"
    ".bash_history"
  ];
}
