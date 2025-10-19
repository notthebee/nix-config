{
  jre,
  fetchFromGitHub,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "prometheus-shellyplug-exporter";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "easimon";
    repo = "shelly-exporter";
    rev = version;
    hash = "sha256-I8yVMX+mlgYjkdj/lo3mKr9JQ6b3d0bT0r0q1jj4z4g=";
  };

  mvnHash = "sha256-MfmQR1tALUNsZXP2b77uns5sxNt6y2P4V8s0+VcTnTs=";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/prometheus-shellyplug-exporter
    install -Dm644 target/shelly-*.jar $out/share/prometheus-shellyplug-exporter

    makeWrapper ${jre}/bin/java $out/bin/prometheus-shellyplug-exporter \
      --add-flags "-jar $out/share/prometheus-shellyplug-exporter/shelly-*.jar"
  '';

  patches = [ ./metrics.patch ];

  meta.mainProgram = "prometheus-shellyplug-exporter";

}
