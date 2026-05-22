{
  pkgs,
  ...
}:
{
  options = { };

  configs = {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [
      ];
    };
  };
}
