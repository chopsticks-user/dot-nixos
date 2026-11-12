# layers on the framework's bottles (prev.bottles) to drop the warning popup on this machine
{ prev, ... }: prev.bottles.override { removeWarningPopup = true; }
