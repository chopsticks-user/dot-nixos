# system side of one user; imported once per users/<name> by mk-machine.nix
{ username, userPersist }:
{
  lib,
  options,
  config,
  pkgs,
  ...
}:
let
  home = config.home-manager.users.${username};
in
{
  sops.secrets."password/${username}".neededForUsers = true;

  users.users.${username} = {
    inherit (home.user) description;
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."password/${username}".path;
    extraGroups = home.user.groups;
    shell = pkgs.${home.user.shell};
  };

  environment = lib.optionalAttrs (options.environment ? persistence) {
    persistence."/persist".users.${username} =
      let
        # a module with a home half persists only for users who enable it, the rest for everyone
        owned = lib.filterAttrs (name: _: home.modules.${name}.enable or true) config.persist.home;
        materialized = lib.attrValues owned ++ [ userPersist ];
      in
      {
        directories = lib.concatMap (p: p.directories or [ ]) materialized;
        files = lib.concatMap (p: p.files or [ ]) materialized;
      };
  };
}
