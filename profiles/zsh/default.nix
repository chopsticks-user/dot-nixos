{ ... }:
{
  options = { };

  configs = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
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
    };
  };
}
