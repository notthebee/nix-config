{
  lib,
  stdenv,
  fixDarwinDylibNames,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      packageOverrides = pkgs: {
        # https://github.com/NixOS/nixpkgs/commit/3070d8a681fab94a2dd108de4b151e0def7e8868
        ghostscript = pkgs.ghostscript.overrideAttrs (oldAttrs: {
          dylib_version = lib.versions.major oldAttrs.version;
          nativeBuildInputs =
            oldAttrs.nativeBuildInputs
            ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;
          postInstall = builtins.replaceStrings [
            ''
              for file in $out/lib/*.dylib* ; do
                install_name_tool -id "$file" $file
              done
            ''
          ] [ "" ] oldAttrs.postInstall;
          preFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
            for file in $out/bin/{gs,gsc,gsx}; do
              install_name_tool -change libgs.$dylib_version.dylib $out/lib/libgs.$dylib_version.dylib $file
            done
          '';
        });
      };
    };
  };

  services.karabiner-elements.enable = true;
  nix = {
    settings = {
      max-jobs = "auto";
      trusted-users = [
        "root"
        "notthebee"
        "@admin"
      ];
    };
  };
}
