{
  lib,
  requireFile,
}: let
  # sha256 obtained by "nix hash file --sri --type sha256 <INSTALLER_ZIP>"
  versions = [
    {
      version = "5.7.4";
      sha256 = "sha256-P6Ho0lc6+36NKX/czHDlqo/f7GyWlrjuk3JT4F4Oucs=";
      installer = "Linux_Unreal_Engine_5.7.4.zip";
    }
  ];
in
  lib.flip map versions ({
    version,
    sha256,
    installer,
  }: {
    inherit version;
    src = requireFile {
      name = installer;
      message = ''
        This nix expression requires that ${installer} is already part of
        the store. Login to Epic Games store to download the Unreal Engine
        binaries on https://www.unrealengine.com/linux and add it to the
        nix store by running
          "nix store add --mode flat --hash-algo sha256 <INSTALLER_ZIP>"
      '';
      inherit sha256;
    };
  })
