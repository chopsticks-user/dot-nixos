{
  lib,
  constants,
  pkgs,
  ...
}@args:
{
  options = { };

  configs = lib.mkMerge [
    (lib.mergeImports [
      ./themes.nix
      ./fonts.nix
      ./xdg.nix
      ./tools.nix
    ] args)
    {
      home = {
        stateVersion = constants.version;
        inherit (constants) username homeDirectory;
      };

      sops = {
        age.sshKeyPaths = [ constants.directories.home.identity ];
        defaultSopsFile = ../../secrets/users/${constants.username}.yaml;
      };

      home.sessionVariables = {
        SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i ${constants.directories.home.identity}";
        SHELL = "${pkgs.${constants.shell}}/bin/${constants.shell}";
        TERMINAL = "${pkgs.${constants.terminal}}/bin/${constants.terminal}";
      };
    }
  ];
}
