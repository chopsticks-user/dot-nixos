{
  lib,
  utils,
  ...
}@args:
(utils.mkProfile "discord" {
  options = { };

  configs =
    { lib, ... }:
    {
      nixpkgs.config.allowUnfreePackages = [
        "discord"
      ];

      programs.discord = {
        enable = true;
        settings = lib.mkForce {
          DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = false;
          SKIP_HOST_UPDATE = true;
          BACKGROUND_COLOR = "#121214";
          openH264Enabled = true;
          offloadAdmControls = true;
          chromiumSwitches = { };
          MINIMIZE_TO_TRAY = false;
          IS_MAXIMIZED = true;
          IS_MINIMIZED = false;
        };
      };
    };
})
  args
