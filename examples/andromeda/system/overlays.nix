# overlays shipped with dot-nixos are opt-in; this machine's own overlays/ and patches/ need no wiring
{
  overlays = {
    unreal-engine.enable = true;
    bottles = {
      enable = true;
      args.removeWarningPopup = true;
    };
  };
}
