{
  pkgs,
  config,
  ...
}:
{
  nixpkgs.config.allowUnfreePackages = [
    "obsidian"
    "spotify"
    "claude-code"
    "discord"
    "discord-unwrapped"
  ];

  home.packages = with pkgs; [
    godot
    blender
    gimp-with-plugins
    krita
    obsidian
    hyprmod
    spotify
    discord

    # agent tooling; higgsfield-faceless-video assembles videos locally with ffmpeg and python3
    bun
    nodejs_latest
    uv
    llm-agents.claude-desktop
    ffmpeg
    python3
    # unpinned on purpose: always runs the latest published Higgsfield CLI
    (writeShellScriptBin "higgsfield" ''
      exec ${nodejs_latest}/bin/npx --yes --package=@higgsfield/cli@latest higgsfield "$@"
    '')
  ];

  modules = {
    zsh.enable = true;
    ssh.enable = true;
    git.enable = true;
    hyprland.enable = true;
    neovim.enable = true;
    firefox.enable = true;
    gaming.enable = true;
    obs.enable = true;
    virtualization.enable = true;
    zed.enable = true;
    vscode.enable = true;
    llm.enable = true;
  };

  # claude-mem hooks call the bare `claude-mem` launcher it installs here; the
  # VS Code extension runs its own bundled claude, so the wrapper below doesn't cover it
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  programs.claude-code = {
    package = pkgs.claude-code.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/claude --suffix PATH : ${config.home.homeDirectory}/.local/bin
      '';
    });
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

  # Unreal Editor popups (overlays/unreal-engine) steal focus and animate otherwise
  wayland.windowManager.hyprland.settings.window_rule = [
    {
      no_anim = true;
      match = {
        class = "^(UnrealEditor)$";
        title = "^\\w*$";
      };
    }
    {
      no_initial_focus = true;
      match = {
        class = "^(UnrealEditor)$";
        title = "^\\w*$";
      };
    }
    {
      no_focus = true;
      match = {
        class = "^(UnrealEditor)$";
        title = "^$";
      };
    }
  ];

  # run `distrobox assemble create --file ~/.config/distrobox/containers.ini` if it doesn't exist
  programs.distrobox.containers.arch = {
    image = "archlinux:latest";
    init = false;
    volume = "${config.user.directories.projects}:${config.user.directories.projects}";
    additional_packages = "base-devel git clang cmake ninja rust";
    pre_init_hooks = [ "export SHELL=/bin/bash" ];
    init_hooks = [
      "rm -rf /tmp/paru"
      "cd /tmp && sudo -u ${config.home.username} git clone https://aur.archlinux.org/paru.git"
      "cd /tmp/paru && sudo -u ${config.home.username} makepkg --noconfirm"
      "pacman -U --noconfirm /tmp/paru/paru-*.pkg.tar.zst"
    ];
  };
}
