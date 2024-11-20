{ config, vars, ... }:
let
  directories = [
    "${vars.serviceConfigRoot}/timetagger"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      timetagger = {
        image = "ghcr.io/almarklein/timetagger:latest";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.timetagger.rule=Host(`time.${vars.domainName}`)"
          "-l=traefik.http.services.timetagger.loadbalancer.server.port=80"
          "-l=homepage.group=Services"
          "-l=homepage.name=TimeTagger"
          "-l=homepage.icon=timetagger.png"
          "-l=homepage.href=https://time.${vars.domainName}"
          "-l=homepage.description=Time tracking software"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/timetagger:/opt/_timetagger"
        ];
        environment = {
          TIMETAGGER_BIND = "0.0.0.0:80";
          TIMETAGGER_DATADIR = "/opt/_timetagger";
          TIMETAGGER_LOG_LEVEL = "info";
          TIMETAGGER_CREDENTIALS = "test:$2y$10$Dx3.YyZPmQepWfNoiK6Jpe1vo6XPaT7Q34IKmR4hvBO24gTf1GFAW";
        };
      };
    };
  };
}
