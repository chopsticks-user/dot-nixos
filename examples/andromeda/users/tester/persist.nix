{
  directories = [
    "boxes"
    ".xdg-ignore"
    ".doppler"
    {
      directory = ".gnupg";
      mode = "0700";
    }
    {
      directory = ".nixops";
      mode = "0700";
    }
    ".config/dconf"
    ".config/sops-nix"
    ".local/share/applications"
    ".local/share/icons"
    {
      directory = ".local/share/keyrings";
      mode = "0700";
    }
    ".local/state/nix"
    ".local/state/home-manager"
    ".cache/nix"
  ]
  ++ [
    ".config/JetBrains"
    ".local/share/JetBrains"
    ".cache/JetBrains"
  ];
  files = [
    ".bash_history"
  ];
}
