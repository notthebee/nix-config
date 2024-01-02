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
        "-l=homepage.group=Arr"
        "-l=homepage.name=Deluge"
        "-l=homepage.icon=deluge.svg"
        "-l=homepage.href=https://deluge.${vars.domainName}"
        "-l=homepage.description=Torrent client"
        "-l=homepage.widget.type=deluge"
        "-l=homepage.widget.password=deluge"
        "-l=homepage.widget.url=http://gluetun:8112"
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
        "-l=homepage.group=Arr"
        "-l=homepage.name=Gluetun"
        "-l=homepage.icon=gluetun.svg"
        "-l=homepage.href=https://deluge.${vars.domainName}"
        "-l=homepage.description=VPN killswitch"
        "-l=homepage.widget.type=gluetun"
        "-l=homepage.widget.url=http://gluetun:8000"
        ];
        ports = [
          "127.0.0.1:8083:8000"
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
