{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "sensor-exporter";
  version = "master";

  src = fetchFromGitHub {
    owner = "ncabatoff";
    repo = "sensor-exporter";
    rev = "${version}";
    sha256 = "YY3V3U+Gx2c1ilX2Tss3+T8wSLiq7YYcRcARCzTeRCc=";
  };

  vendorHash = null;
  doCheck = false;

  subPackages = [ "sensor-exporter/main.go" ];


  meta = with lib; {
    description = "Prometheus exporter for sensor data like temperature and fan speed";
    homepage = "https://github.com/ncabatoff/sensor-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ ncabatoff ];
    platforms = platforms.linux;
  };
}
