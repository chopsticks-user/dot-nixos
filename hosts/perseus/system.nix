{
  config,
  constants,
  ...
}: {
  features = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
  };

  sops = {
    secrets = {
      "networking/wifi/home/ssid" = {};
      "networking/wifi/home/password" = {};
    };
    templates."wifi.env" = {
      content = ''
        WIFI_HOME_SSID=${config.sops.placeholder."networking/wifi/home/ssid"}
        WIFI_HOME_PASSWORD=${config.sops.placeholder."networking/wifi/home/password"}
      '';
    };
  };

  networking = {
    hostName = constants.hostname;
    networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [config.sops.templates."wifi.env".path];
        profiles = {
          home = {
            connection = {
              id = "home";
              type = "wifi";
              autoconnect = "true";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$WIFI_HOME_SSID";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$WIFI_HOME_PASSWORD";
            };
            ipv4 = {
              method = "auto";
            };
          };
        };
      };
    };
  };

  time.timeZone = "America/New_York";
}
