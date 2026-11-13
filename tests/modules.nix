# unit tests for defineModule, evaluated with stand-ins for the NixOS options it writes to
{ lib, test }:
let
  inherit (lib) mkOption types;

  stubs = {
    options = {
      nixpkgs.config.allowUnfreePackages = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      assertions = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
      };
      value = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  # present only on machines that import impermanence
  impermanence = {
    options.environment.persistence = mkOption {
      type = types.attrsOf (types.attrsOf (types.listOf types.anything));
      default = { };
    };
  };

  demo =
    { fields, ... }:
    {
      imports = [ { options.imported = mkOption { default = "always"; }; } ];
      options.level = mkOption {
        type = types.int;
        default = 1;
      };
      configs.value = [ "on-${toString fields.level}" ];
      extraConfigs.value = [ "extra" ];
      allowUnfree = [ "unfree-pkg" ];
      assertions = [
        {
          assertion = fields.level < 5;
          message = "level too high";
        }
      ];
      persist.home = {
        directories = [ ".demo" ];
        files = [ ];
      };
      persist.system = {
        directories = [ "/var/lib/demo" ];
        files = [ ];
      };
    };

  eval =
    {
      class ? "nixos",
      name ? "demo",
      settings ? { },
      extra ? [ ],
    }:
    (lib.evalModules {
      modules = [
        stubs
        ../modules/core/persist-options.nix
        (lib.defineModule class name demo)
        { modules.${name} = settings; }
      ]
      ++ extra;
      specialArgs.pkgs = { };
    }).config;

  off = eval { };
  on = eval { settings.enable = true; };
in
test "modules" {
  testEnableOptionDefaultsOff = {
    expr = off.modules.demo.enable;
    expected = false;
  };
  testOwnOptionsDeclared = {
    expr = off.modules.demo.level;
    expected = 1;
  };
  testDisabledSetsNothing = {
    expr = {
      inherit (off) value assertions;
      persist = off.persist.home;
    };
    expected = {
      value = [ ];
      assertions = [ ];
      persist = { };
    };
  };
  testEnabledAppliesConfigsAndExtraConfigs = {
    expr = lib.sort lib.lessThan on.value;
    expected = [
      "extra"
      "on-1"
    ];
  };
  testFieldsAreTheModuleOptions = {
    expr =
      lib.elem "on-3"
        (eval {
          settings = {
            enable = true;
            level = 3;
          };
        }).value;
    expected = true;
  };
  testImportsApplyRegardlessOfEnable = {
    expr = off.imported;
    expected = "always";
  };
  testAllowUnfreeAppliesWhileDisabled = {
    expr = off.nixpkgs.config.allowUnfreePackages;
    expected = [ "unfree-pkg" ];
  };
  testAssertionsPassThroughWhenEnabled = {
    expr = map (a: a.assertion) on.assertions;
    expected = [ true ];
  };
  testFailingAssertionReported = {
    expr =
      map (a: a.assertion)
        (eval {
          settings = {
            enable = true;
            level = 9;
          };
        }).assertions;
    expected = [ false ];
  };
  testPersistHomeRecordedUnderModuleName = {
    expr = on.persist.home;
    expected = {
      demo = {
        directories = [ ".demo" ];
        files = [ ];
      };
    };
  };
  testPersistSystemIgnoredWithoutImpermanence = {
    expr = on ? environment;
    expected = false;
  };
  testPersistSystemAppliedWithImpermanence = {
    expr =
      (eval {
        settings.enable = true;
        extra = [ impermanence ];
      }).environment.persistence;
    expected = {
      "/persist" = {
        directories = [ "/var/lib/demo" ];
        files = [ ];
      };
    };
  };
  testCoreHasNoEnableAndIsAlwaysOn = {
    expr =
      let
        core = eval { name = "core"; };
      in
      {
        enable = core.modules.core ? enable;
        value = lib.elem "on-1" core.value;
      };
    expected = {
      enable = false;
      value = true;
    };
  };
  testHomeHalfSkipsAssertionsAndPersistence = {
    expr =
      let
        home = eval {
          class = "home";
          settings.enable = true;
        };
      in
      {
        inherit (home) assertions;
        persist = home.persist.home;
        value = lib.elem "on-1" home.value;
      };
    expected = {
      assertions = [ ];
      persist = { };
      value = true;
    };
  };
}
