{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [
    ];
  };
}
