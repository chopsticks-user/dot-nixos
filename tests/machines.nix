# evaluates the fixture machines in machines/ with mkMachine, the way a consumer's flake does, and
# checks what the framework derives from their files
{
  lib,
  mkMachine,
  test,
}:
let
  basicSystem = (mkMachine ./machines/basic).nixosConfigurations.basic;
  basic = basicSystem.config;
  alice = basic.home-manager.users.alice;
  bob = basic.home-manager.users.bob;

  imp = (mkMachine ./machines/impermanent).nixosConfigurations.impermanent.config;

  # a copy of the basic fixture without one file, relative to the fixture root
  without =
    file:
    builtins.path {
      path = ./machines/basic;
      name = "basic-without";
      filter = path: _: lib.removePrefix (toString ./machines/basic) path != file;
    };
  fails = dir: !(builtins.tryEval (builtins.attrNames (mkMachine dir).nixosConfigurations)).success;

  persisted =
    config: user:
    let
      entry = config.environment.persistence."/persist".users.${user};
    in
    {
      directories = lib.sort lib.lessThan (map (d: d.directory) entry.directories);
      files = lib.sort lib.lessThan (map (f: f.file) entry.files);
    };
  coreHome = [
    ".config/nixos"
    ".ssh"
    "documents"
    "downloads"
    "media"
    "pictures"
    "projects"
  ];
in
test "machines" {
  testOutputNamedAfterHostName = {
    expr = builtins.attrNames (mkMachine ./machines/basic).nixosConfigurations;
    expected = [ "basic" ];
  };
  testUsersFromDirectories = {
    expr = lib.attrNames (lib.filterAttrs (_: u: u.isNormalUser) basic.users.users);
    expected = [
      "alice"
      "bob"
    ];
  };
  testAccountFieldsFromHomeNix = {
    expr = {
      inherit (basic.users.users.alice) description extraGroups;
    };
    expected = {
      description = "Alice";
      extraGroups = [
        "wheel"
        "video"
      ];
    };
  };
  testAccountDefaults = {
    expr = {
      inherit (basic.users.users.bob) description extraGroups;
    };
    expected = {
      description = "";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };
  testLoginShells = {
    expr = {
      alice = lib.getName basic.users.users.alice.shell;
      bob = lib.getName basic.users.users.bob.shell;
      zsh = basic.programs.zsh.enable;
      fish = basic.programs.fish.enable;
    };
    expected = {
      alice = "zsh";
      bob = "bash-interactive";
      zsh = true;
      fish = false;
    };
  };
  testShellExported = {
    expr = {
      alice = lib.hasSuffix "/bin/zsh" alice.home.sessionVariables.SHELL;
      bob = lib.hasSuffix "/bin/bash" bob.home.sessionVariables.SHELL;
    };
    expected = {
      alice = true;
      bob = true;
    };
  };
  testTerminalUnsetByDefault = {
    expr = bob.home.sessionVariables ? TERMINAL;
    expected = false;
  };
  testPasswordSecretsForRootAndEveryUser = {
    expr = map (name: basic.sops.secrets.${name}.neededForUsers) [
      "password/root"
      "password/alice"
      "password/bob"
    ];
    expected = [
      true
      true
      true
    ];
  };
  testHostKeyWithoutImpermanence = {
    expr = basic.sops.age.sshKeyPaths;
    expected = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
  testNoImpermanenceWithoutPersistNix = {
    expr = basic.environment ? persistence;
    expected = false;
  };
  testWifiFromSecrets = {
    expr =
      let
        profile = basic.networking.networkmanager.ensureProfiles.profiles.home;
      in
      {
        secrets = lib.all (name: basic.sops.secrets ? ${name}) [
          "networking/wifi/home/ssid"
          "networking/wifi/home/password"
        ];
        priority = profile.connection.autoconnect-priority;
        inherit (profile.wifi) ssid;
        environmentFiles = lib.length basic.networking.networkmanager.ensureProfiles.environmentFiles;
      };
    expected = {
      secrets = true;
      priority = "50";
      ssid = "$WIFI_HOME_SSID";
      environmentFiles = 1;
    };
  };
  testEthernetProfile = {
    expr =
      basic.networking.networkmanager.ensureProfiles.profiles.ethernet.connection.autoconnect-priority;
    expected = "100";
  };
  testSystemHalfFollowsUsers = {
    expr = {
      ssh = basic.modules.ssh.enable;
      sshd = basic.services.openssh.enable;
      gaming = basic.modules.gaming.enable;
    };
    expected = {
      ssh = true;
      sshd = true;
      gaming = false;
    };
  };
  testSystemOnlyModuleFromMachine = {
    expr = {
      docs = basic.modules.docs.enable;
      dev = basic.documentation.dev.enable;
    };
    expected = {
      docs = true;
      dev = true;
    };
  };
  testHomeHalfOnlyForUsersWhoEnableIt = {
    expr = {
      alice = alice.programs.zsh.enable;
      bob = bob.programs.zsh.enable;
    };
    expected = {
      alice = true;
      bob = false;
    };
  };
  testMachineOverlays = {
    expr = {
      package = basicSystem.pkgs.greeting.name;
      patch = baseNameOf (toString (lib.last basicSystem.pkgs.hello.patches));
      frameworkLayer = basicSystem.pkgs ? llm-agents;
    };
    expected = {
      package = "greeting";
      patch = "01-test.patch";
      frameworkLayer = true;
    };
  };
  # alice installs greeting from her own pkgs, which only has it through the machine's overlays
  testUsersGetTheMachineOverlays = {
    expr = lib.elem "greeting" (map (p: p.name) alice.home.packages);
    expected = true;
  };
  testHomeStateVersionFollowsSystem = {
    expr = bob.home.stateVersion;
    expected = basic.system.stateVersion;
  };
  testUserSecretsFileWhenPresent = {
    expr = lib.hasSuffix "/users/alice/secrets.yaml" (toString alice.sops.defaultSopsFile);
    expected = true;
  };
  testPlainGitIdentityNeedsNoSecrets = {
    expr = {
      inherit (alice.programs.git.settings.user) name email;
      secrets = alice.sops.secrets;
    };
    expected = {
      name = "Alice";
      email = "alice@example.com";
      secrets = { };
    };
  };
  testXdgDirectoriesFromWellKnownPaths = {
    expr = {
      inherit (bob.xdg.userDirs) documents download;
    };
    expected = {
      documents = "/home/bob/documents";
      download = "/home/bob/downloads";
    };
  };
  testFrameworkCommandsInstalled = {
    expr = lib.all (name: lib.elem name (map (p: p.name or "") basic.environment.systemPackages)) [
      "nixos-secrets"
      "nixos-homestrap"
      "nix-system"
      "nix"
    ];
    expected = true;
  };
  testBasicIsAWholeSystem = {
    expr = lib.hasSuffix ".drv" basic.system.build.toplevel.drvPath;
    expected = true;
  };

  testHostKeyUnderPersist = {
    expr = imp.sops.age.sshKeyPaths;
    expected = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };
  testPersistNeededForBoot = {
    expr = imp.fileSystems."/persist".neededForBoot;
    expected = true;
  };
  testSystemPersistence = {
    expr = {
      directories = lib.sort lib.lessThan (
        map (d: d.directory) imp.environment.persistence."/persist".directories
      );
      files = map (f: f.file) imp.environment.persistence."/persist".files;
    };
    expected = {
      directories = [
        "/etc/ssh"
        "/var/lib/nixos"
        "/var/log"
      ];
      files = [ "/etc/machine-id" ];
    };
  };
  # core, then zsh and firefox for enabling them, then her persist.nix; pictures sits outside
  # media in this fixture, so it is kept on its own
  testPersistenceForUserWithModules = {
    expr = persisted imp "alice";
    expected = {
      directories = lib.sort lib.lessThan (
        coreHome
        ++ [
          ".config/zsh"
          ".local/share/zoxide"
          ".mozilla"
          ".cache/mozilla"
          ".gnupg"
        ]
      );
      files = [
        ".bash_history"
        ".zsh_history"
      ];
    };
  };
  testPersistenceForUserWithoutModules = {
    expr = persisted imp "bob";
    expected = {
      directories = coreHome;
      files = [ ];
    };
  };
  testUserKeyDirectoryPrivate = {
    expr =
      (lib.findFirst (d: d.directory == ".ssh") {
        mode = "missing";
      } imp.environment.persistence."/persist".users.bob.directories).mode;
    expected = "0700";
  };
  testImpermanentIsAWholeSystem = {
    expr = lib.hasSuffix ".drv" imp.system.build.toplevel.drvPath;
    expected = true;
  };

  testFilteredCopyEvaluates = {
    expr = fails (without "/nothing");
    expected = false;
  };
  testMissingDiskLayoutFails = {
    expr = fails (without "/hardware/disk.nix");
    expected = true;
  };
  testMissingHardwareFails = {
    expr = fails (without "/hardware/default.nix");
    expected = true;
  };
  testMissingSystemFails = {
    expr = fails (without "/system/default.nix");
    expected = true;
  };
  testMissingSecretsFails = {
    expr = fails (without "/secrets.yaml");
    expected = true;
  };
  testUserWithoutHomeNixFails = {
    expr = fails (without "/users/bob/home.nix");
    expected = true;
  };
}
