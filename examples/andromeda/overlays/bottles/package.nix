# layers on the bottles below this layer (prev.bottles) to drop the warning popup on this machine
{ prev, ... }: prev.bottles.override { removeWarningPopup = true; }
