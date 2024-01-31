{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/homeassistant"
];
  in
{

  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      scrutiny = {
        image = "homeassistant/home-assistant:stable";
        autoStart = true;
        extraOptions = [
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.homeassistant.rule=Host(`home.${vars.domainName}`)"
        "-l=traefik.http.services.homeassistant.loadbalancer.server.port=8123"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/homeassistant:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "1000";
          GUID = "1000";
        };
      };
    };
};
}
