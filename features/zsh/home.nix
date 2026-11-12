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

        execnhu() {
          nohup setsid "$@" >/dev/null 2>&1 &
        }
      '';
    };
  };
}
