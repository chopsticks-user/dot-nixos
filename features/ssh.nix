{
  lib,
  config,
  ...
}:
let
  cfg = config.features.ssh;
in
{
  options.features.ssh.enable = lib.mkEnableOption "ssh";

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };
}
