{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.steam-config-nix.homeModules.default
  ];

  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  home.packages = with pkgs; [
    steam
    steam-run
    protonup-qt
    protontricks
  ];

  # steam launch options: gamemoderun gamescope -f -e -- mangohud %command%
  programs.steam.config = {
    enable = true;
    closeSteam = true;
    defaultCompatTool = "proton_experimental";

    apps = {};
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
  };
}
