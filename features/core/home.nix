{
  lib,
  pkgs,
  config,
  ...
}@args:
{
  imports = [ ./options.nix ];

  options = { };

  configs = lib.mkMerge [
    (lib.mergeImports [
      ./directories.nix
      ./preferences.nix
    ] args)
    {
      sops = {
        age.sshKeyPaths = [ config.user.directories.identity ];
      };

      home.sessionVariables = {
        SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i ${config.user.directories.identity}";
        SHELL = "${pkgs.${config.user.shell}}/bin/${config.user.shell}";
        TERMINAL = "${pkgs.${config.user.terminal}}/bin/${config.user.terminal}";
      };
    }
  ];
}
