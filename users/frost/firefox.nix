{ ... }: {
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
}
