{ ... }:
{
  options = { };

  configs = {
    # agents run binaries they download themselves (uv Python, prebuilt wheels, npx tools)
    programs.nix-ld.enable = true;
  };

  persist.home = {
    directories = [ ".claude" ];
    files = [ ];
  };
}
