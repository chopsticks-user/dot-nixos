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

  persist.home = {
    directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
    files = [ ];
  };
}
