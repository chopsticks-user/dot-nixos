{
  lib,
  pkgs,
  inputs,
  ...
}@args:
(lib.utils.mkProfile "gaming" {
  imports = [
    inputs.steam-config-nix.homeModules.default
  ];

  options = { };

  configs =
    { ... }:
    {
      home.packages = with pkgs; [
        gamemode
        gamescope
        steam
        steam-run
        protonup-qt
        protontricks
      ];

      systemd.user.services.gamemoded = {
        Unit.Description = "Game mode daemon";
        Service = {
          ExecStart = "${pkgs.gamemode}/bin/gamemoded -r";
          Restart = "always";
        };
        Install.WantedBy = [ "default.target" ];
      };

      nixpkgs.config.allowUnfreePackages = [
        "steam"
        "steam-unwrapped"
      ];

      # steam launch options: gamemoderun gamescope -f -e -- mangohud %command%
      programs.steam.config = {
        enable = true;
        closeSteam = true;
        defaultCompatTool = "proton_experimental";
        apps = { };
      };

      home.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
      };

      programs = {
        mangohud = {
          enable = true;
          settings = {
            fps = true;
            cpu_temp = true;
            gpu_temp = true;
            ram = true;
            vram = true;
            frame_timing = true;
          };
        };
      };
    };
})
  args
