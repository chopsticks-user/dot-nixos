{pkgs, ...}: {
  home.packages = with pkgs; [
    gamemode
    gamescope
  ];

  systemd.user.services.gamemoded = {
    Unit.Description = "Game mode daemon";
    Service = {
      ExecStart = "${pkgs.gamemode}/bin/gamemoded -r";
      Restart = "always";
    };
    Install.WantedBy = ["default.target"];
  };

  # todo: enable at system level to provide cpu-governed optimizations
  # services.gamemode.enable = true;
}
