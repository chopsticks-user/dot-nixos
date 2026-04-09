{ constants, ... }: {
  programs.firefox = {
    enable = true;
    profiles."${constants.username}" = {
      settings = {
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.constant-theme" = 2;
        "browser.theme.toolbar-theme" = 2;
      };
    };
  };
}
