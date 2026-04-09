{pkgs, ...}: {
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
      # fortune | cowsay | lolcat

      setopt PROMPT_SUBST
      _nix_prompt_char() {
        case $IN_NIX_SHELL in
          pure) print -n "%F{208}%#%f" ;;
          impure) print -n "%F{red}%#%f" ;;
          *) print -n "%#" ;;
        esac
      }
      PROMPT='[%F{blue}%*%f %F{yellow}%n@%m%f %F{green}%2~%f]$(_nix_prompt_char) '
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
}
