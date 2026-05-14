{
  lib,
  ...
}@args:
(lib.utils.mkProfile "claude" {
  options = { };

  configs =
    { ... }:
    {
      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;
      };
    };
})
  args
