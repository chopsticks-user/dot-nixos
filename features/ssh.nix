{
  lib,
  ...
}@args:
(lib.mkFeature "ssh" {
  options = { };

  configs =
    { ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
    };
})
  args
