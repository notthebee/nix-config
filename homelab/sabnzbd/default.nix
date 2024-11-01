{ pkgs, vars, ... }:
let
  directories = [
    "${vars.serviceConfigRoot}/sabnzbd"
    "${vars.mainArray}/Media/Downloads"
    "${vars.cacheArray}/Media/Downloads"
    "${vars.serviceConfigRoot}/sabnzbd:/config"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      sabnzbd = {
        image = "linuxserver/sabnzbd:latest";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=homepage.group=Arr"
          "-l=homepage.name=sabnzbd"
          "-l=homepage.icon=sabnzbd.svg"
          "-l=homepage.href=https://sabnzbd.${vars.domainName}"
          "-l=homepage.description=Newsgroup client"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.sabnzbd.rule=Host(`sabnzbd.${vars.domainName}`)"
          "-l=traefik.http.routers.sabnzbd.service=sabnzbd"
          "-l=traefik.http.services.sabnzbd.loadbalancer.server.port=8080"
        ];
        volumes = [
          "${vars.mainArray}/Media/Downloads:/data/completed"
          "${vars.cacheArray}/Media/Downloads.tmp:/data/incomplete"
          "${vars.serviceConfigRoot}/sabnzbd:/config"
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
