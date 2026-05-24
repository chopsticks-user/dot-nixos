{
  config,
  constants,
  ...
}:
{
  features = {
    grub.enable = true;
    nh.enable = true;
    docs.enable = true;
    fcitx.enable = true;
  };

  sops = {
    secrets = {
      "networking/wifi/home/ssid" = { };
      "networking/wifi/home/password" = { };
    };
    templates."wifi.env" = {
      content = ''
        WIFI_0_SSID=${config.sops.placeholder."networking/wifi/home/ssid"}
        WIFI_0_PASSWORD=${config.sops.placeholder."networking/wifi/home/password"}
      '';
    };
  };

  networking = {
    hostName = constants.hostname;
    networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [ config.sops.templates."wifi.env".path ];
        profiles = {
          wifi-0 = {
            connection = {
              id = "wifi-0";
              type = "wifi";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$WIFI_0_SSID";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$WIFI_0_PASSWORD";
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
