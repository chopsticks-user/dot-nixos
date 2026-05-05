{
  autoPatchelfHook,
  buildFHSEnv,
  callPackage,
  lib,
  stdenv,
  version ? null,
  source ? null,
  unzip,
  writeShellScript,
  makeDesktopItem,
  # extensions
  extraPkgs ? _: [],
  extraProfile ? "",
  extraPreBwrapCmds ? "",
  extraBwrapArgs ? [],
  extraArgs ? "",
  extraEnv ? {},
  privateTmp ? true,
  # required for ue-unwrapped
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  avahi,
  bzip2,
  cairo,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdbm,
  glib,
  libdrm,
  libGL,
  libGLU,
  libuuid,
  libxkbcommon,
  lttng-ust,
  lz4,
  mesa,
  ncurses5,
  nspr,
  nss,
  pango,
  readline,
  sqlite,
  xz,
  zlib,
  zstd,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libgbm,
  libxcb,
  # runtime only
  clang,
  cmake,
  dotnet-sdk,
  glibc,
  vulkan-loader,
  udev,
  gnumake,
  openssl,
  vulkan-validation-layers,
  libX11,
  libXext,
  libXrender,
  libXi,
  libXcursor,
  libXrandr,
  libXScrnSaver,
  libXfixes,
  libXcomposite,
  libXdamage,
  pulseaudio,
  libpulseaudio,
  gcc,
  libXinerama,
  curl,
  gtk3,
  libxslt,
  icu,
  SDL2,
  systemd,
  cups,
  gdk-pixbuf,
}: let
  unreal-engine-unwrapped = let
    defaultTarget = let
      versions = callPackage ./versions.nix {};
    in
      if version == null
      then lib.head versions
      else
        lib.findFirst (v: v.version == version)
        (throw "No registered Unreal Engine version found to match version=${toString version}")
        versions;
  in
    stdenv.mkDerivation {
      pname = "unreal-engine-unwrapped";
      inherit (defaultTarget) version;
      src = lib.defaultTo defaultTarget.src source;
      sourceRoot = ".";
      nativeBuildInputs = [
        unzip
      ];
      noDumpEnvVars = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r . $out
        rm -f $out/rc
        runHook postInstall
      '';
      dontConfigure = true;
      dontBuild = true;
      dontPatchELF = true;
      noAuditTmpdir = true;
      preferLocalBuild = true;
      dontStrip = true;
    };

  buildRuntimeEnv = {
    extraPkgs ? _: [],
    extraProfile ? "",
    extraPreBwrapCmds ? "",
    extraBwrapArgs ? [],
    extraEnv ? {},
    privateTmp ? true,
    ...
  } @ args:
    buildFHSEnv (
      (removeAttrs args [
        "extraPkgs"
        "extraProfile"
        "extraPreBwrapCmds"
        "extraBwrapArgs"
        "extraArgs"
        "extraEnv"
      ])
      // {
        inherit privateTmp;

        targetPkgs = pkgs:
          [
            glibc
            vulkan-loader
            udev
            clang
            cmake
            dotnet-sdk
            gnumake
            openssl

            # vulkan
            vulkan-loader
            vulkan-validation-layers
            mesa
            libGL
            libGLU

            # X11 libraries
            libX11
            libXext
            libXrender
            libXi
            libXcursor
            libXrandr
            libXinerama
            libxcb
            libXScrnSaver
            libXfixes
            libXcomposite
            libXdamage

            # Audio
            alsa-lib
            pulseaudio
            libpulseaudio

            # Core system libraries
            glibc
            stdenv.cc.cc.lib
            gcc.cc.lib

            # Other runtime dependencies
            libxkbcommon
            fontconfig
            freetype
            zlib
            openssl
            curl
            gtk3
            ncurses5
            libuuid
            libxslt
            icu
            SDL2
            udev
            systemd
            dbus
            nss
            nspr
            at-spi2-atk
            at-spi2-core
            cups
            libdrm
            expat
            cairo
            pango
            gdk-pixbuf
            glib
            atk
            libgbm
          ]
          ++ extraPkgs pkgs;

        profile = ''
          export LD_LIBRARY_PATH=/usr/lib64:/usr/lib:$LD_LIBRARY_PATH

          set -a
          ${lib.toShellVars extraEnv}
          set +a

          ${extraProfile}
        '';

        extraPreBwrapCmds = ''
          export UE_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/unreal-engine"

          mkdir -p "$UE_CACHE"/{upper,work}
          MARKER="$UE_CACHE/upper/.initialized-$(basename ${unreal-engine-unwrapped})"
          if [ ! -e "$MARKER" ]; then
            rm -f "$UE_CACHE/upper"/.initialized-*
            (cd ${unreal-engine-unwrapped} && find . -type d -print0) \
              | (cd "$UE_CACHE/upper" && xargs -0 mkdir -p)
            touch "$MARKER"
          fi

          ${extraPreBwrapCmds}
        '';

        extraBwrapArgs =
          [
            "--overlay-src"
            "${unreal-engine-unwrapped}"

            "--overlay"
            "\${UE_CACHE}/upper"
            "\${UE_CACHE}/work"
            "${unreal-engine-unwrapped}"
          ]
          ++ extraBwrapArgs;
      }
    );
in
  buildRuntimeEnv {
    pname = "unreal-engine";
    inherit (unreal-engine-unwrapped) version;

    inherit
      extraProfile
      extraPreBwrapCmds
      extraBwrapArgs
      extraEnv
      privateTmp
      ;
    extraPkgs = pkgs: [unreal-engine-unwrapped] ++ extraPkgs pkgs;

    runScript = writeShellScript "unreal-engine-wrapped" ''
      exec ${unreal-engine-unwrapped}/Engine/Binaries/Linux/UnrealEditor ${extraArgs} "$@"
    '';

    extraInstallCommands = let
      desktopItem = makeDesktopItem {
        name = "unreal-engine";
        desktopName = "Unreal Engine";
        comment = "Unreal Engine 5 Editor";
        exec = "unreal-engine %F";
        icon = "unreal-engine";
        terminal = false;
        type = "Application";
        categories = ["Development" "IDE"];
        startupNotify = false;
      };
    in ''
      install -Dm444 ${desktopItem}/share/applications/unreal-engine.desktop \
        $out/share/applications/unreal-engine.desktop
      install -Dm444 ${unreal-engine-unwrapped}/Engine/Content/Editor/Slate/Icons/EditorAppIcon.png \
        $out/share/icons/hicolor/24x24/apps/unreal-engine.png
    '';

    meta = {
      description = "The most powerful real-time 3D creation tool";
      homepage = "https://www.unrealengine.com/";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      maintainers = [];
      platforms = ["x86_64-linux"];
      mainProgram = "unreal-engine";
    };

    passthru = let
      makeRunner = {
        pname,
        packages,
        license,
      }:
        buildRuntimeEnv {
          inherit pname;
          inherit (unreal-engine-unwrapped) version;

          inherit
            extraProfile
            extraPreBwrapCmds
            extraBwrapArgs
            extraEnv
            privateTmp
            ;
          extraPkgs = pkgs: packages ++ extraPkgs pkgs;

          runScript = writeShellScript pname ''
            if [ $# -eq 0 ]; then
              echo "Usage: ${pname} command-to-run args..." >&2
              exit 1
            fi
            exec "$@"
          '';

          meta = {
            description = "Run commands in the FHS environment used for Unreal Engine";
            mainProgram = pname;
            inherit license;
            platforms = ["x86_64-linux"];
          };
        };
    in {
      inherit buildRuntimeEnv;
      run = makeRunner {
        pname = "unreal-engine-run";
        packages = [unreal-engine-unwrapped];
        license = lib.licenses.unfree;
      };
      run-free = makeRunner {
        pname = "unreal-engine-run-free";
        packages = [];
        license = lib.licenses.free;
      };
    };
  }
