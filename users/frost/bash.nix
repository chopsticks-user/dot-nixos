{ ... }: {
  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	start-hyprland
      fi
    '';
  };
}
