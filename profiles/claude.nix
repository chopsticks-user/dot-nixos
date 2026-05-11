{
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.claude;
in
{
  options.profiles.claude = {
    enable = lib.mkEnableOption "claude";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
    };
  };
}
