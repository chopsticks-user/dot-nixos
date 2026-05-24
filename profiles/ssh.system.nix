{ ... }:
{
  options = { };

  configs = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };

  persist.home = username: {
    directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
    files = [ ];
  };
}
