{
  lib,
  pkgs,
  ...
}@args:
(lib.utils.mkProfile "zsh" {
  options = {
    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Shell aliases to add to zsh";
    };
  };

  configs =
    { fields, ... }:
    {
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
        inherit (fields) shellAliases;
        history = {
          size = 10000;
          ignoreDups = true;
          ignoreAllDups = true;
        };
        initContent = ''
          setopt PROMPT_SUBST
          _prompt_info() {
            local info=""
            info+="[l=$SHLVL,p=$(ps -o comm= -p $PPID)]"
            echo "$info"
          }
          PROMPT="[%F{blue}%*%f %F{yellow}%n@%m%f %F{green}%2~%f]\$(_prompt_info)%% "

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

          execnhu() {
            nohup setsid "$@" >/dev/null 2>&1 &
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
})
  args
