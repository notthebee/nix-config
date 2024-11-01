{ config, vars, ... }:
let
  directories = [
    "${vars.serviceConfigRoot}/grafana"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 472 0 - -") directories;
  virtualisation.oci-containers = {
    containers = {
      grafana = {
        image = "grafana/grafana";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.grafana.rule=Host(`grafana.${vars.domainName}`)"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/grafana:/var/lib/grafana"
        ];
      };
    };
  };
}
