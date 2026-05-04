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
  libxcb,
  # runtime only
  clang,
  cmake,
  dotnet-sdk,
  glibc,
  vulkan-loader,
  udev,
}: let
  versions = callPackage ./versions.nix {};

  found-version =
    if version == null
    then lib.head versions
    else
      lib.findFirst (v: v.version == version)
      (throw "No registered Unreal Engine version found to match version=${toString version}")
      versions;

  src =
    if source == null
    then found-version.src
    else source;

  unwrappedLibs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    avahi
    bzip2
    cairo
    dbus
    libdrm
    expat
    mesa
    gdbm
    glib
    libGL
    libGLU
    lttng-ust
    lz4
    xz
    ncurses5
    nspr
    nss
    pango
    readline
    sqlite
    libuuid
    libxkbcommon
    zlib
    zstd
    fontconfig
    freetype
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];

  runtimeLibs =
    unwrappedLibs
    ++ [
      glibc
      vulkan-loader
      udev
      clang
      cmake
      dotnet-sdk
    ];

  ue-unwrapped = stdenv.mkDerivation {
    pname = "unreal-engine";
    inherit (found-version) version;
    inherit src;
    sourceRoot = ".";
    nativeBuildInputs = [
      autoPatchelfHook
      unzip
    ];
    buildInputs = unwrappedLibs;
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
    preferLocalBuild = true;
    dontStrip = true;
    autoPatchelfIgnoreMissingDeps = [
      "libandroid.so"
      "libc.musl-x86_64.so.1"
      "libc++_shared.so"
      "libgdbm.so.4"
      "libGLESv3.so"
      "libicudata.so.53"
      "libicudata.so.64"
      "libicui18n.so.53"
      "libicui18n.so.64"
      "libicule.so.53"
      "libicutu.so.64"
      "libicuuc.so.53"
      "libicuuc.so.64"
      "liblog.so"
      "liblttng-ust.so.0"
      "libOpenSLES.so"
      "libpskernel.so"
      "libreadline.so.6"
      "libUnrealEditor-uLangCore.so"
    ];
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
          runtimeLibs
          ++ extraPkgs pkgs;

        profile = ''
          # SDL2 inotify fallback — udev events unreliable in bwrap containers
          export SDL_JOYSTICK_DISABLE_UDEV=1

          # Use system GPU drivers from NixOS
          export LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri:/run/opengl-driver-32/lib/dri
          export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d:/run/opengl-driver-32/share/glvnd/egl_vendor.d
          export LIBVA_DRIVERS_PATH=/run/opengl-driver/lib/dri:/run/opengl-driver-32/lib/dri
          export VDPAU_DRIVER_PATH=/run/opengl-driver/lib/vdpau:/run/opengl-driver-32/lib/vdpau

          set -a
          ${lib.toShellVars extraEnv}
          set +a

          ${extraProfile}
        '';

        extraPreBwrapCmds = ''
          export UE_CACHE="$HOME/.cache/unreal-engine"
          mkdir -p "$UE_CACHE"/{upper,work}

          MARKER="$UE_CACHE/upper/.initialized-$(basename ${ue-unwrapped})"
          if [ ! -e "$MARKER" ]; then
            rm -f "$UE_CACHE/upper"/.initialized-*
            (cd ${ue-unwrapped} && find . -type d -print0) \
              | (cd "$UE_CACHE/upper" && xargs -0 mkdir -p)
            touch "$MARKER"
          fi

          ${extraPreBwrapCmds}
        '';

        extraBwrapArgs =
          [
            "--overlay-src"
            "${ue-unwrapped}"

            "--overlay"
            "\${UE_CACHE}/upper"
            "\${UE_CACHE}/work"
            "${ue-unwrapped}"
          ]
          ++ extraBwrapArgs;
      }
    );
in
  buildRuntimeEnv {
    name = "unreal-engine";
    inherit (found-version) version;

    inherit
      extraProfile
      extraPreBwrapCmds
      extraBwrapArgs
      extraEnv
      privateTmp
      ;
    extraPkgs = pkgs: [ue-unwrapped] ++ extraPkgs pkgs;

    runScript = writeShellScript "unreal-engine-launcher" ''
      export LD_LIBRARY_PATH=/usr/lib64:/usr/lib:$LD_LIBRARY_PATH
      exec ${ue-unwrapped}/Engine/Binaries/Linux/UnrealEditor ${extraArgs} "$@"
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
      install -Dm444 ${ue-unwrapped}/Engine/Content/Editor/Slate/Icons/EditorAppIcon.png \
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
        name,
        packages,
        license,
      }:
        buildRuntimeEnv {
          inherit name;

          inherit
            extraProfile
            extraPreBwrapCmds
            extraBwrapArgs
            extraEnv
            privateTmp
            ;
          extraPkgs = pkgs: packages ++ extraPkgs pkgs;

          runScript = writeShellScript name ''
            if [ $# -eq 0 ]; then
              echo "Usage: ${name} command-to-run args..." >&2
              exit 1
            fi
            exec "$@"
          '';

          meta = {
            description = "Run commands in the FHS environment used for Unreal Engine";
            mainProgram = name;
            inherit license;
            platforms = ["x86_64-linux"];
          };
        };
    in {
      inherit buildRuntimeEnv;
      run = makeRunner {
        name = "unreal-engine-run";
        packages = [ue-unwrapped];
        license = lib.licenses.unfree;
      };
      run-free = makeRunner {
        name = "unreal-engine-run-free";
        packages = [];
        license = lib.licenses.free;
      };
    };
  }
