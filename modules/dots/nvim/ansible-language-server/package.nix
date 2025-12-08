{
  pkgs,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "ansible-language-server";
  version = "25.12.1";
  src = pkgs.fetchFromGitHub {
    owner = "ansible";
    repo = "vscode-ansible";
    tag = "v${version}";
    hash = "sha256-N/6m3E6WKrgss4cGRYccBmxCCG8vPfvQlFGrnjh4kSM=";
  };
  buildInputs = [
    pkgs.nodejs
    pkgs.corepack
    pkgs.yarn
    pkgs.cacert
  ];
  buildPhase = ''
    export HOME=$(pwd)
    yarn install --immutable
    yarn run compile
  '';
  postPatch = ''
    cp ${./yarn.lock} yarn.lock
    if [ -f .yarnrc.yml ]; then
      sed -i '/yarnPath:/d' .yarnrc.yml
    fi
  '';
  installPhase = ''
    mkdir -p $out
    cp -r packages/ansible-language-server/* $out/
    cp -r out/* $out/out
    rm -rf node_modules/@ansible
    cp -r node_modules/* $out/node_modules
  '';
  meta.mainProgram = "ansible-language-server";
}
