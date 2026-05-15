{
  lib,
  constants,
  ...
}@args:
(lib.utils.mkProfile "firefox" {
  options = { };

  configs =
    { ... }:
    {
      programs.firefox = {
        enable = true;
        profiles."${constants.username}" = {
          settings = {
            "accessibility.browsewithcaret" = true;
            "accessibility.typeaheadfind.flashBar" = 0;
            "app.normandy.first_run" = false;
            "app.normandy.migrationsApplied" = 12;
            "app.normandy.user_id" = "7f755613-d654-4310-b40b-e964534e9959";
            "app.shield.optoutstudies.enabled" = false;
            "app.update.lastUpdateTime.addon-background-update-timer" = 1775861134;
            "app.update.lastUpdateTime.browser-cleanup-thumbnails" = 1775940872;
            "app.update.lastUpdateTime.glean-addons-daily" = 1775861134;
            "app.update.lastUpdateTime.recipe-client-addon-run" = 1775937112;
            "app.update.lastUpdateTime.region-update-timer" = 1775861134;
            "app.update.lastUpdateTime.rs-experiment-loader-timer" = 1775942920;
            "app.update.lastUpdateTime.services-settings-poll-changes" = 1775861134;
            "app.update.lastUpdateTime.suggest-ingest" = 1775861106;
            "app.update.lastUpdateTime.xpi-signature-verification" = 1775861134;
            "browser.aboutConfig.showWarning" = false;
            "browser.bookmarks.addedImportButton" = true;
            "browser.bookmarks.restore_default_bookmarks" = false;
            "browser.bookmarks.showMobileBookmarks" = false;
            "browser.contentblocking.category" = "standard";
            "browser.contextual-services.contextId" = "613ed61d-3ae4-4059-901c-5e1279888397";
            "browser.contextual-services.contextId.timestamp-in-seconds" = 1775861105;
            "browser.ctrlTab.sortByRecentlyUsed" = true;
            "browser.download.useDownloadDir" = false;
            "browser.download.viewableInternally.typeWasRegistered.avif" = true;
            "browser.download.viewableInternally.typeWasRegistered.webp" = true;
            "browser.eme.ui.firstContentShown" = true;
            "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
            "browser.firefox-view.feature-tour" = "{\"screen\":\"\",\"complete\":true}";
            "browser.ipProtection.locationListCache" =
              "[{\"name\":\"CatchAll Anycast\",\"code\":\"US\",\"cities\":[{\"name\":\"USA\",\"code\":\"Q30\",\"servers\":[{\"port\":2499,\"hostname\":\"p.m1.fastly-masque.net\",\"quarantined\":false,\"protocols\":[{\"name\":\"connect\",\"host\":\"p.m1.fastly-masque.net\",\"port\":2499,\"scheme\":\"https\"}]}]}]}]";
            "browser.laterrun.bookkeeping.profileCreationTime" = 1775861104;
            "browser.laterrun.bookkeeping.sessionCount" = 1;
            "browser.laterrun.enabled" = true;
            "browser.migration.version" = 165;
            "browser.ml.chat.nimbus" =
              "ai-chatbot-page-summarization-mvp-treatment-a-callout-badge-rollout-v4:treatment-a-callout-badge";
            "browser.newtabpage.activity-stream.discoverystream.sections.interestPicker.visibleSections" =
              "top_stories_section,small-wins,food,in-the-zeitgeist,music,nfl,headlines,downtime,home,connections,government,education,photojournalism,featured-videos,arts,explained,society-parenting,long-reads,education-science,finance";
            "browser.newtabpage.activity-stream.discoverystream.spoc.impressions" =
              "{\"CAISC2ZpbmFuY2VidXp6\":[1775937082483,1775937090186,1775937102235,1775937111903,1775938517013,1775940980355,1775941029671,1775941875062,1775942339466,1775943302589],\"CAISEmVuZXJneWJpbGxjcnVuY2hlcg\":[1775943302607]}";
            "browser.newtabpage.activity-stream.impressionId" = "{b9612aa1-b3e0-4491-9a58-f586ebeb0239}";
            "browser.newtabpage.activity-stream.telemetry.surfaceId" = "NEW_TAB_EN_US";
            "browser.newtabpage.enabled" = true;
            "browser.newtabpage.pinned" = "[]";
            "browser.newtabpage.storageVersion" = 1;
            "browser.pageActions.persistedActions" =
              "{\"ids\":[\"bookmark\"],\"idsInUrlbar\":[\"bookmark\"],\"idsInUrlbarPreProton\":[],\"version\":1}";
            "browser.pagethumbnails.storage_version" = 3;
            "browser.policies.applied" = true;
            "browser.proton.toolbar.version" = 3;
            "browser.region.update.updated" = 1775861105;
            "browser.rights.3.shown" = true;
            "browser.safebrowsing.provider.mozilla.lastupdatetime" = "1775937082270";
            "browser.safebrowsing.provider.mozilla.nextupdatetime" = "1775958682270";
            "browser.search.region" = "US";
            "browser.search.serpEventTelemetryCategorization.regionEnabled" = true;
            "browser.search.totalSearches" = 64;
            "browser.sessionstore.upgradeBackup.latestBuildID" = "20260403140140";
            "browser.shell.mostRecentDateSetAsDefault" = "1775942919";
            "browser.startup.couldRestoreSession.count" = 1;
            "browser.startup.homepage_override.buildID" = "20260403140140";
            "browser.startup.homepage_override.mstone" = "149.0.2";
            "browser.startup.lastColdStartupCheck" = 1775942920;
            "browser.startup.page" = 3;
            "browser.termsofuse.prefMigrationCheck" = true;
            "browser.theme.constant-theme" = 2;
            "browser.theme.toolbar-theme" = 0;
            "browser.toolbars.bookmarks.visibility" = "always";
            "browser.topsites.contile.cacheValidFor" = 10800;
            "browser.topsites.contile.lastFetch" = 1775943221;
            "browser.uiCustomization.state" =
              "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"_6b733b82-9261-47ee-a595-2dda294a4d08_-browser-action\",\"addon_darkreader_org-browser-action\",\"_react-devtools-browser-action\",\"stringieee_gmail_com-browser-action\",\"_dbd5152f-0107-427d-96a5-416684b6e50b_-browser-action\",\"song-id_losnappas-browser-action\",\"_bc118c9c-5c07-4347-b502-657d03d87065_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"customizableui-special-spring2\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"unified-extensions-button\",\"ublock0_raymondhill_net-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"firefox-view-button\",\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"import-button\",\"personal-bookmarks\"]},\"seen\":[\"developer-button\",\"screenshot-button\",\"_6b733b82-9261-47ee-a595-2dda294a4d08_-browser-action\",\"addon_darkreader_org-browser-action\",\"_react-devtools-browser-action\",\"stringieee_gmail_com-browser-action\",\"_dbd5152f-0107-427d-96a5-416684b6e50b_-browser-action\",\"song-id_losnappas-browser-action\",\"_bc118c9c-5c07-4347-b502-657d03d87065_-browser-action\",\"ublock0_raymondhill_net-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"PersonalToolbar\",\"unified-extensions-area\",\"toolbar-menubar\",\"TabsToolbar\"],\"currentVersion\":23,\"newElementCount\":2}";
            "browser.urlbar.lastUrlbarSearchSeconds" = 1775943310;
            "browser.urlbar.placeholderName" = "Google";
            "browser.urlbar.quickactions.timesShownOnboardingLabel" = 3;
            "browser.urlbar.quicksuggest.migrationVersion" = 7;
            "captchadetection.lastSubmission" = 1775861;
            "datareporting.dau.cachedUsageProfileGroupID" = "6771f1c8-a03a-475f-8321-ca59138861e9";
            "datareporting.dau.cachedUsageProfileID" = "45314a77-42c5-4c6c-816a-9f7309bc1f12";
            "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
            "datareporting.policy.dataSubmissionPolicyNotifiedTime" = "1775861105720";
            "devtools.everOpened" = true;
            "devtools.toolsidebar-height.inspector" = 350;
            "devtools.toolsidebar-width.inspector" = 700;
            "devtools.toolsidebar-width.inspector.splitsidebar" = 350;
            "devtools.webextensions.@react-devtools.enabled" = true;
            "devtools.webextensions.{a5260852-8d08-4979-8116-38f1129dfd22}.enabled" = true;
            "distribution.iniFile.exists.appversion" = "149.0.2";
            "distribution.iniFile.exists.value" = true;
            "distribution.nixos.bookmarksProcessed" = true;
            "doh-rollout.doneFirstRun" = true;
            "doh-rollout.home-region" = "US";
            "doh-rollout.skipHeuristicsCheck" = true;
            "dom.forms.autocomplete.formautofill" = true;
            "dom.push.userAgentID" = "5c4506e5c7dc4732b218cd97698b33de";
            "extensions.activeThemeID" = "default-theme@mozilla.org";
            "extensions.blocklist.pingCountVersion" = -1;
            "extensions.colorway-builtin-themes-cleanup" = 1;
            "extensions.databaseSchema" = 37;
            "extensions.dnr.lastStoreUpdateTag.7c2b640a-d211-460e-a3d5-201281aab9be" =
              "{e40b0787-aff8-4a49-bc8b-df029d1a7703}";
            "extensions.getAddons.cache.lastUpdate" = 1775861135;
            "extensions.getAddons.databaseSchema" = 6;
            "extensions.lastAppBuildId" = "20260403140140";
            "extensions.lastAppVersion" = "149.0.2";
            "extensions.lastPlatformVersion" = "149.0.2";
            "extensions.pendingOperations" = false;
            "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
            "extensions.quarantinedDomains.list" =
              "autoatendimento.bb.com.br,ibpf.sicredi.com.br,ibpj.sicredi.com.br,internetbanking.caixa.gov.br,www.ib12.bradesco.com.br,www2.bancobrasil.com.br";
            "extensions.signatureCheckpoint" = 1;
            "extensions.webextensions.ExtensionStorageIDB.migrated.@react-devtools" = true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.addon@darkreader.org" = true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.song-id@losnappas" = true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.stringieee@gmail.com" = true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.uBlock0@raymondhill.net" = true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.{6b733b82-9261-47ee-a595-2dda294a4d08}" =
              true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.{a5260852-8d08-4979-8116-38f1129dfd22}" =
              true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.{bc118c9c-5c07-4347-b502-657d03d87065}" =
              true;
            "extensions.webextensions.ExtensionStorageIDB.migrated.{dbd5152f-0107-427d-96a5-416684b6e50b}" =
              true;
            "extensions.webextensions.uuids" =
              "{\"data-leak-blocker@mozilla.com\":\"34bca731-768d-4491-a47d-4f1b1527a16d\",\"formautofill@mozilla.org\":\"1162f606-c985-4b3f-902f-34caa3738ce0\",\"ipp-activator@mozilla.com\":\"3262c851-ede5-4c48-9924-094ed6d25189\",\"pictureinpicture@mozilla.org\":\"14bdffd6-a019-404c-9431-968e93ccf28b\",\"addons-search-detection@mozilla.com\":\"e21a77aa-1514-43a4-8342-788a228a1695\",\"webcompat@mozilla.org\":\"9a310967-e580-48bf-b3e8-4eafebbc122d\",\"newtab@mozilla.org\":\"6bcef125-a757-4438-8400-9869c7584629\",\"default-theme@mozilla.org\":\"96821c29-0378-4acc-8fe4-f67219e2c41c\",\"{6b733b82-9261-47ee-a595-2dda294a4d08}\":\"7c2b640a-d211-460e-a3d5-201281aab9be\",\"{a5260852-8d08-4979-8116-38f1129dfd22}\":\"e9c39ecf-0326-4b2d-a49c-e2b9180acde8\",\"addon@darkreader.org\":\"9fe72872-a0a0-4060-8bac-a878d34f26da\",\"@react-devtools\":\"fde5f002-e6f1-47ac-a748-bf0022b12491\",\"stringieee@gmail.com\":\"f6bc3c3f-be03-46dd-b2da-6b4fb8c1730f\",\"{dbd5152f-0107-427d-96a5-416684b6e50b}\":\"ebdef3ff-80ce-4630-9b98-8ae998042082\",\"song-id@losnappas\":\"5c6a52f4-9baf-4435-9581-82e0c4031b8d\",\"{bc118c9c-5c07-4347-b502-657d03d87065}\":\"9a14a427-efc7-48fb-999a-2ee36f41bb76\",\"uBlock0@raymondhill.net\":\"3de384de-7cd7-4b75-9eb4-d4a84eb4f7a6\"}";
            "gecko.handlerService.defaultHandlersVersion" = 1;
            "identity.fxaccounts.account.device.name" = "frost’s Firefox on andromeda";
            "identity.fxaccounts.account.telemetry.sanitized_uid" = "31d1bf0e78d6ec5439a65167e01393f3";
            "identity.fxaccounts.commands.missed.last_fetch" = 1775861295;
            "identity.fxaccounts.lastSignedInUserIdHash" = "Z8GqwFGP4/WsTGn51Mo950037FzAPCwEmLT0soB4uI0=";
            "identity.fxaccounts.toolbar.syncSetup.panelAccessed" = true;
            "idle.lastDailyNotification" = 1775864652;
            "media.eme.enabled" = true;
            "media.gmp-gmpopenh264.abi" = "x86_64-gcc3";
            "media.gmp-gmpopenh264.hashValue" =
              "f5246bf14d038adf4ce0c4360262ab722bc3de4220f047c3d542b4c564074b4877dc8659e3125c5171c749e7ce93f20cc63777eb5e1539e960670cbc5f30ac85";
            "media.gmp-gmpopenh264.lastDownload" = 1775861135;
            "media.gmp-gmpopenh264.lastInstallStart" = 1775861135;
            "media.gmp-gmpopenh264.lastUpdate" = 1775861135;
            "media.gmp-gmpopenh264.version" = "2.6.0";
            "media.gmp-manager.buildID" = "20260403140140";
            "media.gmp-manager.lastCheck" = 1775890929;
            "media.gmp-manager.lastEmptyCheck" = 1775890929;
            "media.gmp-widevinecdm.abi" = "x86_64-gcc3";
            "media.gmp-widevinecdm.hashValue" =
              "421214210a09a9f9ed8ce482ef857f1c2b29ce1739240d1ec99a61caa3d80db3393752275722bdf5f503489f12a753215fe8a0c82de3aca23780d4ffe5792eb1";
            "media.gmp-widevinecdm.lastDownload" = 1775861135;
            "media.gmp-widevinecdm.lastInstallStart" = 1775861135;
            "media.gmp-widevinecdm.lastUpdate" = 1775861135;
            "media.gmp-widevinecdm.version" = "4.10.2934.0";
            "media.gmp.storage.version.observed" = 1;
            "media.videocontrols.picture-in-picture.video-toggle.first-seen-secs" = 1775873420;
            "media.videocontrols.picture-in-picture.video-toggle.has-used" = true;
            "network.cookie.CHIPS.lastMigrateDatabase" = 2;
            "network.dns.disablePrefetch" = true;
            "network.http.speculative-parallel-limit" = 0;
            "network.prefetch-next" = false;
            "nimbus.migrations.after-remote-settings-update" = 0;
            "nimbus.migrations.after-store-initialized" = 3;
            "nimbus.migrations.init-started" = 1;
            "nimbus.profileId" = "56572d98-64de-4498-98c9-5b1a9881642c";
            "nimbus.rollouts.enabled" = false;
            "pdfjs.enabledCache.state" = true;
            "pdfjs.migrationVersion" = 2;
            "places.database.lastMaintenance" = 1775864652;
            "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;
            "privacy.clearOnShutdown_v2.formdata" = true;
            "privacy.purge_trackers.date_in_cookie_database" = "0";
            "privacy.purge_trackers.last_purge" = "1775864652845";
            "privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs3" = true;
            "privacy.sanitize.pending" = "[{\"id\":\"newtab-container\",\"itemsToClear\":[],\"options\":{}}]";
            "privacy.trackingprotection.allow_list.hasMigratedCategoryPrefs" = true;
            "services.settings.blocklists.addons-bloomfilters.last_check" = 1775941242;
            "services.settings.blocklists.gfx.last_check" = 1775941242;
            "services.settings.clock_skew_seconds" = -999;
            "services.settings.last_etag" = "1775941040051";
            "services.settings.last_update_seconds" = 1775943047;
            "services.settings.main.addons-data-leak-blocker-domains.last_check" = 1775941242;
            "services.settings.main.addons-manager-settings.last_check" = 1775941242;
            "services.settings.main.anti-tracking-url-decoration.last_check" = 1775941242;
            "services.settings.main.bounce-tracking-protection-exceptions.last_check" = 1775941242;
            "services.settings.main.cfr.last_check" = 1775941242;
            "services.settings.main.cookie-banner-rules-list.last_check" = 1775941242;
            "services.settings.main.devtools-compatibility-browsers.last_check" = 1775941242;
            "services.settings.main.devtools-devices.last_check" = 1775941242;
            "services.settings.main.doh-config.last_check" = 1775941242;
            "services.settings.main.doh-providers.last_check" = 1775941242;
            "services.settings.main.fingerprinting-protection-overrides.last_check" = 1775941242;
            "services.settings.main.fxmonitor-breaches.last_check" = 1775941242;
            "services.settings.main.fxrelay-allowlist.last_check" = 1775941242;
            "services.settings.main.fxrelay-denylist.last_check" = 1775941242;
            "services.settings.main.hijack-blocklists.last_check" = 1775941242;
            "services.settings.main.language-dictionaries.last_check" = 1775941242;
            "services.settings.main.message-groups.last_check" = 1775941242;
            "services.settings.main.moz-essential-domain-fallbacks.last_check" = 1775941242;
            "services.settings.main.ms-language-packs.last_check" = 1775941242;
            "services.settings.main.newtab-frecency-boosted-sponsors.last_check" = 1775941242;
            "services.settings.main.newtab-wallpapers-v2.last_check" = 1775941242;
            "services.settings.main.nimbus-desktop-experiments.last_check" = 1775941242;
            "services.settings.main.nimbus-secure-experiments.last_check" = 1775941242;
            "services.settings.main.normandy-recipes-capabilities.last_check" = 1775941242;
            "services.settings.main.partitioning-exempt-urls.last_check" = 1775941242;
            "services.settings.main.password-recipes.last_check" = 1775941242;
            "services.settings.main.password-rules.last_check" = 1775941242;
            "services.settings.main.query-stripping.last_check" = 1775941242;
            "services.settings.main.remote-permissions.last_check" = 1775941242;
            "services.settings.main.search-categorization.last_check" = 1775941242;
            "services.settings.main.search-config-icons.last_check" = 1775941242;
            "services.settings.main.search-config-overrides-v2.last_check" = 1775941242;
            "services.settings.main.search-config-v2.last_check" = 1775941242;
            "services.settings.main.search-default-override-allowlist.last_check" = 1775941242;
            "services.settings.main.search-telemetry-v2.last_check" = 1775941242;
            "services.settings.main.sites-classification.last_check" = 1775941242;
            "services.settings.main.third-party-cookie-blocking-exempt-urls.last_check" = 1775941242;
            "services.settings.main.tippytop.last_check" = 1775941242;
            "services.settings.main.top-sites.last_check" = 1775941242;
            "services.settings.main.tracking-protection-lists.last_check" = 1775941242;
            "services.settings.main.translations-models-v2.last_check" = 1775941242;
            "services.settings.main.translations-models.last_check" = 1775941242;
            "services.settings.main.translations-wasm.last_check" = 1775941242;
            "services.settings.main.url-classifier-exceptions.last_check" = 1775941242;
            "services.settings.main.url-classifier-skip-urls.last_check" = 1775941242;
            "services.settings.main.url-parser-default-unknown-schemes-interventions.last_check" = 1775941242;
            "services.settings.main.urlbar-persisted-search-terms.last_check" = 1775941242;
            "services.settings.main.vpn-serverlist.last_check" = 1775941242;
            "services.settings.main.webcompat-interventions.last_check" = 1775941242;
            "services.settings.main.websites-with-shared-credential-backends.last_check" = 1775941242;
            "services.settings.security-state.cert-revocations.last_check" = 1775941242;
            "services.settings.security-state.intermediates.last_check" = 1775941242;
            "services.settings.security-state.onecrl.last_check" = 1775941242;
            "services.sync.addons.lastSync" = "1775861170.66";
            "services.sync.addons.syncID" = "aMLPpkPnJF1q";
            "services.sync.addresses.lastSync" = "0";
            "services.sync.client.GUID" = "EhlphWZ9hB4O";
            "services.sync.client.syncID" = "_gwRqqCSEbQs";
            "services.sync.clients.devices.desktop" = 3;
            "services.sync.clients.devices.mobile" = 0;
            "services.sync.clients.lastRecordUpload" = 1775942921;
            "services.sync.clients.lastSync" = "1775942921.29";
            "services.sync.clients.syncID" = "YHf5v39gjZ9e";
            "services.sync.creditcards.lastSync" = "0";
            "services.sync.declinedEngines" = "addresses,creditcards";
            "services.sync.engine.addresses.available" = true;
            "services.sync.engine.prefs.modified" = false;
            "services.sync.forms.lastSync" = "1775943522.94";
            "services.sync.forms.syncID" = "i5yGC6QMv5Cw";
            "services.sync.globalScore" = 0;
            "services.sync.lastPing" = 1775861128;
            "services.sync.lastSync" = "Sat Apr 11 2026 17:38:43 GMT-0400 (Eastern Daylight Time)";
            "services.sync.lastTabFetch" = 1775943522;
            "services.sync.nextSync" = 1775944123;
            "services.sync.prefs.lastSync" = "1775861170.28";
            "services.sync.prefs.sync-seen.accessibility.browsewithcaret" = true;
            "services.sync.prefs.sync-seen.app.shield.optoutstudies.enabled" = true;
            "services.sync.prefs.sync-seen.browser.contentblocking.category" = true;
            "services.sync.prefs.sync-seen.browser.ctrlTab.sortByRecentlyUsed" = true;
            "services.sync.prefs.sync-seen.browser.download.useDownloadDir" = true;
            "services.sync.prefs.sync-seen.browser.firefox-view.feature-tour" = true;
            "services.sync.prefs.sync-seen.browser.newtabpage.pinned" = true;
            "services.sync.prefs.sync-seen.browser.startup.page" = true;
            "services.sync.prefs.sync-seen.extensions.activeThemeID" = true;
            "services.sync.prefs.sync-seen.general.autoScroll" = true;
            "services.sync.prefs.sync-seen.media.eme.enabled" = true;
            "services.sync.prefs.sync-seen.nimbus.rollouts.enabled" = true;
            "services.sync.prefs.sync-seen.privacy.clearOnShutdown_v2.formdata" = true;
            "services.sync.prefs.syncID" = "BPga8veHaiPF";
            "services.sync.syncInterval" = 600000;
            "services.sync.syncThreshold" = 300;
            "services.sync.username" = "frostyfrost273@gmail.com";
            "sidebar.backupState" =
              "{\"command\":\"\",\"panelOpen\":false,\"launcherExpanded\":false,\"launcherVisible\":false}";
            "sidebar.notification.badge.aichat" = true;
            "sidebar.visibility" = "hide-sidebar";
            "storage.vacuum.last.index" = 0;
            "storage.vacuum.last.places.sqlite" = 1775864652;
            "toolkit.profiles.storeID" = "1ec47926";
            "toolkit.startup.last_success" = 1775942918;
            "toolkit.telemetry.cachedClientID" = "f91c3544-4940-4ec8-86b2-f5a1f59a942a";
            "toolkit.telemetry.cachedProfileGroupID" = "68b0a63d-bd74-4f90-b7b1-2fd165d89519";
            "toolkit.telemetry.previousBuildID" = "20260403140140";
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "trailhead.firstrun.didSeeAboutWelcome" = true;
            "ui.systemUsesDarkTheme" = 1;
          };
        };
      };
    };
})
  args
