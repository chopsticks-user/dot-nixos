{ config, pkgs, self, ... }: {
  home.stateVersion = self.stateVersion;
  home.username = "frost";
  home.homeDirectory = "/home/frost";
  home.packages = with pkgs; [
    noctalia-shell
    kitty
    neovim
    firefox
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        gaps_out = 5;
        gaps_in = 5;
      };
      exec-once = [
        "noctalia-shell"
      ];
      bind = [
        "SUPER, Return, exec, kitty"
        "SUPER, Q, killactive"
        "SUPER, SPACE, exec, noctalia-shell ipc call launcher toggle"
        "SUPER, C, exec, noctalia-shell ipc call controlCenter toggle"
        "SUPER, S, exec, noctalia-shell ipc call settings toggle"
      ];
    };
  };
  
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/.xdg-ignore";
    templates = "${config.home.homeDirectory}/.xdg-ignore";
    publicShare = "${config.home.homeDirectory}/.xdg-ignore";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
    pictures = "${config.home.homeDirectory}/media/images";
    music = "${config.home.homeDirectory}/media/audio";
    videos = "${config.home.homeDirectory}/media/videos";
    extraConfig = {
      XDG_MEDIA_DIR = "${config.home.homeDirectory}/media";
      XDG_DEV_DIR = "${config.home.homeDirectory}/dev";
      XDG_WALLPAPERS_DIR = "${config.home.homeDirectory}/media/images/wallpapers";
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/media/images/screenshots";
      XDG_SCREENCASTS_DIR = "${config.home.homeDirectory}/media/videos/screencasts";
    };
  };

  xdg.configFile."noctalia-shell/config.json".source = ./noctalia.json;
      programs.bash = {
	enable = true;
	profileExtra = ''
	  if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	    start-hyprland
	  fi
        '';
	shellAliases = {
	  vi = "nvim";
	};
      };
      
  programs.git = {
    enable = true;
    settings = {
      user = {
	name = "chopsticks-user";
	email = "frostyfrost273@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.gh = {
    enable = true;
    settings = {};
  };

      programs.firefox = {
	enable = true;
	profiles.frost = {
	  settings = {
	    "ui.systemUsesDarkTheme" = 1;
	    "browser.theme.constant-theme" = 2;
	    "browser.theme.toolbar-theme" = 2;
	  };
	};
      };

  dconf.settings = {
	"org/gnome/desktop/interface" = {
	  color-scheme = "prefer-dark";
	};
  };

      gtk = {
	enable = true;
        gtk4.theme = {
	  name = "Adwaita-dark";
	  package = pkgs.gnome-themes-extra;
	};
	theme = {
	  name = "Adwaita-dark";
	  package = pkgs.gnome-themes-extra;
	};
      };

      qt = {
	enable = true;
	platformTheme.name = "gtk";
      };

      home.sessionVariables = {
	GTK_THEME = "Adwaita:dark";
      };
}
