{...}: {
  services.mpd = {
    enable = true;
    musicDirectory = "/home/frost";
    network = {
      listenAddress = "any";
      startWhenNeeded = true;
    };
  };

  programs.rmpc = {
    enable = true;
  };
}
