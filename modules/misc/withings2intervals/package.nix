{
  python3Packages,
  python3,
  fetchFromGitHub,
  ...
}:
python3Packages.buildPythonApplication {
  pname = "withings2intervals";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "stezz";
    repo = "withings_syncer";
    rev = "v0.1.1";
    hash = "sha256-QrgqzCQkgrKF46e1j/kTvse+expbSTi+FlyTIktWKog=";
  };
  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3.pkgs; [
    requests
    colorama
    pip
  ];

  meta = {
    description = "A Python script to sync wellness data from Withings to Intervals.icu";
    homepage = "https://github.com/stezz/withings_syncer";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];
    mainProgram = "withings2intervals";
  };
}
