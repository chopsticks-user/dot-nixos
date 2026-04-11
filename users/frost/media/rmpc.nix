{...}: {
  programs.rmpc = {
    enable = true;
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/frost";
    network = {
      listenAddress = "any";
      startWhenNeeded = true;
    };
  };
}
