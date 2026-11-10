{ ... }:
{
  options = { };

  configs = {
    # uv-downloaded Python and the prebuilt wheels claude-mem's chroma-mcp uses need a real dynamic loader
    programs.nix-ld.enable = true;
  };

  persist.home = {
    directories = [
      ".claude"
      ".claude-mem"
      ".impeccable"
    ];
    files = [ ];
  };
}
