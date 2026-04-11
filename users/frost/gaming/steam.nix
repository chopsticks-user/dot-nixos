{pkgs, ...}: {
  home.packages = with pkgs; [
    steam
    steam-run
    protonup-qt
    protontricks
  ];

  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  # todo: at system level
  # programs.steam = {
  #   enable = true;
  #   gamescopeSession.enable = true;
  # };
  #
  # programs.gamemode.enable = true;

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
  };
}
