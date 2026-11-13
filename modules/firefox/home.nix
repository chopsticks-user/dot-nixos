{
  config,
  ...
}:
{
  options = { };

  configs = {
    programs.firefox = {
      enable = true;
      profiles.${config.home.username} = {
        settings = {
          # restore the previous session and ask where to save downloads
          "browser.startup.page" = 3;
          "browser.download.useDownloadDir" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.ctrlTab.sortByRecentlyUsed" = true;
          "browser.aboutConfig.showWarning" = false;
          "sidebar.visibility" = "hide-sidebar";

          # no first-run pages, studies, rollouts or speculative connections
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "app.shield.optoutstudies.enabled" = false;
          "nimbus.rollouts.enabled" = false;
          "network.dns.disablePrefetch" = true;
          "network.prefetch-next" = false;
          "network.http.speculative-parallel-limit" = 0;

          # DRM playback
          "media.eme.enabled" = true;
        };
      };
    };
  };
}
