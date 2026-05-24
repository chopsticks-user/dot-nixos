{
  lib,
  config,
  pkgs,
  constants,
  username,
  hasPersist,
  ...
}:
{
  sops = {
    secrets = {
      "password/${username}" = {
        neededForUsers = true;
      };
    };
  };

  users.users.${username} =
    let
      userMeta = constants.users."${username}";
    in
    {
      inherit (userMeta) description;
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."password/${username}".path;
      extraGroups = userMeta.groups;
      shell = pkgs.${userMeta.shell};
    };

  systemd.services."home-manager-activate-${username}" = {
    after = [
      "nix-daemon.service"
      "local-fs.target"
    ];
    requires = [ "nix-daemon.service" ];
    before = [ "systemd-user-sessions.service" ];
    unitConfig = {
      ConditionFileIsExecutable = "/home/${username}/.local/state/nix/profiles/home-manager/activate";
      RequiresMountsFor = [ "/home/${username}" ];
    };
    serviceConfig = {
      Type = "oneshot";
      User = "${username}";
      ExecStart = "/home/${username}/.local/state/nix/profiles/home-manager/activate";
    };
    path = [ pkgs.nix ];
    wantedBy = [ "multi-user.target" ];
  };

  # todo: remove hasPersist once andromeda has persist.nix
  environment = lib.optionalAttrs hasPersist {
    persistence."/persist".users.${username} =
      let
        materialized = lib.attrValues config.persist.home;
      in
      {
        directories = lib.concatMap (p: p.directories) materialized;
        files = lib.concatMap (p: p.files) materialized;
      };
  };
}
