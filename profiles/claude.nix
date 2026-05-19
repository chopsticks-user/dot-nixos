{
  lib,
  ...
}@args:
(lib.mkProfile "claude" {
  options = { };

  configs =
    { ... }:
    {
      nixpkgs.config.allowUnfreePackages = [
        "claude-code"
      ];

      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;
      };
    };
})
  args
