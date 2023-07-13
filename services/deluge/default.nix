{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/deluge"
"${vars.serviceConfigRoot}/radarr"
"${vars.serviceConfigRoot}/prowlarr"
"${vars.serviceConfigRoot}/recyclarr"
"${vars.mainArray}/Media/Downloads"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      deluge = {
        image = "linuxserver/deluge:latest";
        autoStart = true;
        dependsOn = [
          "gluetun"
        ];
        extraOptions = [
        "--network=container:gluetun"
        ];
        volumes = [
          "${vars.mainArray}/Media/Downloads:/data/completed"
          "${vars.serviceConfigRoot}/deluge:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
        };
      };
      gluetun = {
        image = "qmcgaw/gluetun:latest";
        autoStart = true;
        extraOptions = [
        "--cap-add=NET_ADMIN"
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.deluge.rule=Host(`deluge.${vars.domainName}`)"
        "-l=traefik.http.services.deluge.loadbalancer.server.port=8112"
        "--device=/dev/net/tun:/dev/net/tun"
        ];
        environmentFiles = [
          config.age.secrets.wireguardCredentials.path
        ];
        environment = {
          VPN_TYPE = "wireguard";
          VPN_SERVICE_PROVIDER =  "custom";
        };
      };
    };
};
}
