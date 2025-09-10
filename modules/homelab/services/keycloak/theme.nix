{ stdenv }:
stdenv.mkDerivation rec {
  name = "keycloak_theme_notthebee";
  version = "1.0";

  src = ./themes/notthebee;

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp -a login $out
  '';
}
