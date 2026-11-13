{ ... }:
{
  options = { };

  configs = {
    programs.claude-code = {
      enable = true;
      # claude writes its own settings at runtime, home-manager only seeds them
      mutableSettings = true;
    };
  };
}
