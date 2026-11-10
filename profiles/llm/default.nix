{ pkgs, inputs, ... }:
{
  options = { };

  configs = {
    home.packages =
      let
        llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      in
      with pkgs;
      [
        bun
        nodejs_latest
        uv
        llm-pkgs.claude-desktop
      ];

    programs.claude-code = {
      enable = true;
    };
  };
}
