# no impermanence, one system-only module, one Wi-Fi network
{
  networking.hostName = "basic";
  system.stateVersion = "26.11";
  modules = {
    docs.enable = true;
    core.wifi.home.priority = 50;
  };
}
