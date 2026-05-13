{
  lib,
  ...
}@args:
(lib.utils.mkFeature "ssh" {
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
