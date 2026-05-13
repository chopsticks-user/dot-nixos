{
  utils,
  pkgs,
  ...
}@args:
(utils.mkProfile "obs" {
  options = { };

  configs =
    { ... }:
    {
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs; [
        ];
      };
    };
})
  args
