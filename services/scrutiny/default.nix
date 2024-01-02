{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/scrutiny"
"${vars.serviceConfigRoot}/scrutiny/cron.d"
"${vars.serviceConfigRoot}/scrutiny/config"
"${vars.serviceConfigRoot}/scrutiny/influxdb"
];
  in
{

  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  system.activationScripts.scrutiny_cron_configure = ''
    mkdir -p "${vars.serviceConfigRoot}/scrutiny/cron.d"
    touch "${vars.serviceConfigRoot}/scrutiny/cron.d/scrutiny"
    echo "30 1 * * * root . /env.sh; /opt/scrutiny/bin/scrutiny-collector-metrics run >/proc/1/fd/1 2>/proc/1/fd/2" > "${vars.serviceConfigRoot}/scrutiny/cron.d/scrutiny"
  '';
  virtualisation.oci-containers = {
    containers = {
      scrutiny = {
        image = "ghcr.io/analogj/scrutiny:v0.7.2-omnibus";
        autoStart = true;
        extraOptions = [
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.scrutiny.rule=Host(`scrutiny.${vars.domainName}`)"
        "-l=traefik.http.services.scrutiny.loadbalancer.server.port=8080"
        "-l=homepage.group=Monitoring"
        "-l=homepage.name=Scrutiny"
        "-l=homepage.icon=scrutiny-light.png"
        "-l=homepage.href=https://scrutiny.${vars.domainName}"
        "-l=homepage.description=S.M.A.R.T. monitoring"
        "-l=homepage.widget.type=scrutiny"
        "-l=homepage.widget.url=http://scrutiny:8080"
        "--cap-add=SYS_RAWIO"
        "--device=/dev/sda:/dev/sda"
        "--device=/dev/sdb:/dev/sdb"
        "--device=/dev/sdc:/dev/sdc"
        "--device=/dev/sdd:/dev/sdd"
        "--device=/dev/sde:/dev/sde"
        "--device=/dev/sdf:/dev/sdf"
        "--device=/dev/sdg:/dev/sdg"
        "--device=/dev/sdh:/dev/sdh"
        ];
        volumes = [
          "/run/udev:/run/udev:ro"
          "${vars.serviceConfigRoot}/scrutiny/config:/opt/scrutiny/config"
          "${vars.serviceConfigRoot}/scrutiny/cron.d/scrutiny:/etc/cron.d/scrutiny"
          "${vars.serviceConfigRoot}/scrutiny/influxdb:/opt/scrutiny/influxdb"

        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
        };
      };
    };
};
}
