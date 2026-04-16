{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.profiles.zsh;
in {
  options.profiles.zsh = {
    enable = lib.mkEnableOption "zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      profileExtra = ''
        if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
         start-hyprland
        fi
      '';
      shellAliases = {
      };
      history = {
        size = 10000;
        ignoreDups = true;
        ignoreAllDups = true;
      };
      initContent = ''
        setopt PROMPT_SUBST
        _nix_prompt_char() {
          case $IN_NIX_SHELL in
            pure) print -n "%F{208}%#%f" ;;
            impure) print -n "%F{red}%#%f" ;;
            *) print -n "%#" ;;
          esac
        }
        PROMPT='[%F{blue}%*%f %F{yellow}%n@%m%f %F{green}%2~%f]$(_nix_prompt_char) '

        nh() {
          if [[ "$1 $2" == "home switch" ]]; then
            local os
            case "$(uname -s)" in
              Linux)  os="linux" ;;
              Darwin) os="darwin" ;;
            esac
             command nh home switch -c "$(whoami)@$(uname -m)-''${os}" "''${@:3}"
          else
            command nh "$@"
          fi
        }
      '';
      # plugins = [
      # {
      # name = pkgs.zsh-autosuggestions.pname;
      # src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      # }
      # {
      # name = pkgs.zsh-syntax-highlighting.pname;
      # src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
      # }
      # ];
    };

    home.sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
    };
  };
}
