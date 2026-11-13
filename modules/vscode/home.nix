{
  lib,
  pkgs,
  ...
}:
{
  options = { };

  configs = {
    user.allowUnfree = [
      "vscode"
      "vscode-extension-anthropic-claude-code"
    ];

    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.vscode-extensions; [
          anthropic.claude-code
          jnoortheen.nix-ide
          llvm-vs-code-extensions.vscode-clangd
          golang.go
          detachhead.basedpyright
          mads-hartmann.bash-ide-vscode
          mkhl.direnv
          pkief.material-icon-theme
          enkia.tokyo-night
        ];

        mutableUserSettings = true;
        # language servers are pinned to store paths so extensions never try to download their own
        userSettings = {
          "telemetry.telemetryLevel" = "off";
          "update.mode" = "none";
          "workbench.colorTheme" = "Dark Modern";
          "workbench.preferredDarkColorTheme" = "Tokyo Night";
          "workbench.iconTheme" = "material-icon-theme";
          "window.autoDetectColorScheme" = true;
          "claudeCode.preferredLocation" = "sidebar";
          "git.autofetch" = true;

          "files.autoSave" = "afterDelay";
          "editor.fontSize" = 13;
          "editor.fontFamily" = "FiraCode Nerd Font";
          "editor.fontLigatures" = true;
          "editor.renderWhitespace" = "all";
          "editor.formatOnSave" = true;
          "terminal.integrated.fontFamily" = "FiraCode Nerd Font";

          "nix.enableLanguageServer" = true;
          "nix.serverPath" = lib.getExe pkgs.nixd;
          "nix.serverSettings".nixd.formatting.command = [ (lib.getExe pkgs.nixfmt) ];

          "clangd.path" = lib.getExe' pkgs.clang-tools "clangd";

          "go.toolsManagement.autoUpdate" = false;
          "go.alternateTools".gopls = lib.getExe pkgs.gopls;

          "bashIde.shellcheckPath" = lib.getExe pkgs.shellcheck;
          "bashIde.shfmt.path" = lib.getExe pkgs.shfmt;
        };
      };
    };
  };
}
