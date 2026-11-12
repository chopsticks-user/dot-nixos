{
  pkgs,
  inputs,
  constants,
  ...
}:
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
        # higgsfield-faceless-video assembles videos locally with these
        ffmpeg
        python3
        # unpinned on purpose: always runs the latest published Higgsfield CLI
        (writeShellScriptBin "higgsfield" ''
          exec ${nodejs_latest}/bin/npx --yes --package=@higgsfield/cli@latest higgsfield "$@"
        '')
      ];

    # claude-mem hooks call the bare `claude-mem` launcher it installs here; the
    # VS Code extension runs its own bundled claude, so the wrapper below doesn't cover it
    home.sessionPath = [ "${constants.homeDirectory}/.local/bin" ];

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/claude --suffix PATH : ${constants.homeDirectory}/.local/bin
        '';
      });
      mutableSettings = true;
      settings = {
        # hooks inherit this env; claude-mem lets it override ~/.claude-mem/settings.json
        env.CLAUDE_MEM_CONTEXT_SHOW_TERMINAL_OUTPUT = "true";
        extraKnownMarketplaces = {
          thedotmack.source = {
            source = "github";
            repo = "thedotmack/claude-mem";
          };
          ponytail.source = {
            source = "github";
            repo = "DietrichGebert/ponytail";
          };
          impeccable.source = {
            source = "github";
            repo = "pbakaus/impeccable";
          };
          higgsfield.source = {
            source = "github";
            repo = "higgsfield-ai/skills";
          };
        };
        enabledPlugins = {
          "claude-mem@thedotmack" = true;
          "ponytail@ponytail" = true;
          "impeccable@impeccable" = true;
          "higgsfield@higgsfield" = true;
          "gopls-lsp@anthropic-plugin-directory" = true;
          "clangd-lsp@anthropic-plugin-directory" = true;
          "jdtls-lsp@anthropic-plugin-directory" = true;
          "csharp-lsp@anthropic-plugin-directory" = true;
          "typescript-lsp@anthropic-plugin-directory" = true;
        };
        pluginConfigs."ponytail@ponytail".options = {
          ledger = true;
          sendNames = false;
        };
      };
      mcpServers.context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
      };
    };
  };
}
