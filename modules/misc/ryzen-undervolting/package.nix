{
  stdenv,
  pkgs,
  ...
}:
stdenv.mkDerivation {
  pname = "ryzen-undervolting";
  version = "0.1";
  dontUnpack = true;
  src = pkgs.fetchFromGitHub {
    owner = "svenlange2";
    repo = "Ryzen-5800x3d-linux-undervolting";
    rev = "c08815d1eca6f63585e8ef8f711706e75d5739aa";
    hash = "sha256-Ec50QDNkBYNbAVUrUr6Ac4G6MDIkBdXrjSJ2skMlulc=";
  };
  installPhase = ''
    runHook preInstall
    install -Dm755 $src/ruv.py $out/bin/ruv.py;
    runHook postInstall
  '';

  meta = {
    description = "Ryzen 5800x3d undervolting utility";
    homepage = "https://github.com/svenlange2/Ryzen-5800x3d-linux-undervolting";
    platforms = [ "x86_64-linux" ];
    mainProgram = "ruv.py";
  };
}
