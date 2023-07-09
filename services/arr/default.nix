{ config, vars, ... }:
  let
directories = [
"${vars.serviceConfigRoot}/sonarr"
"${vars.serviceConfigRoot}/radarr"
"${vars.serviceConfigRoot}/prowlarr"
"${vars.serviceConfigRoot}/recyclarr"
"${vars.mainArray}/Media/Downloads"
"${vars.mainArray}/Media/Plex/TV"
"${vars.mainArray}/Media/Plex/Movies"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      prowlarr = {
        image = "binhex/arch-prowlarr";
        autoStart = true;
        ports = [ "9696:9696" ];
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.prowlarr.rule=Host(`prowlarr.${vars.domainName}`)"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/prowlarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          UMASK = "002";
        };
      };
      sonarr = {
        image = "lscr.io/linuxserver/sonarr";
        autoStart = true;
        ports = [ "8989:8989" ];
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.sonarr.rule=Host(`sonarr.${vars.domainName}`)"
        ];
        volumes = [
            "${vars.mainArray}/Media/Downloads:/downloads"
            "${vars.mainArray}/Media/Plex/TV:/tv"
            "${vars.serviceConfigRoot}/sonarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          UMASK = "002";
        };
      };
      radarr = {
        image = "lscr.io/linuxserver/radarr";
        autoStart = true;
        ports = [ "7878:7878" ];
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.radarr.rule=Host(`radarr.${vars.domainName}`)"
        ];
        volumes = [
            "${vars.mainArray}/Media/Downloads:/downloads"
            "${vars.mainArray}/Media/Plex/Movies:/tv"
            "${vars.serviceConfigRoot}/radarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          UMASK = "002";
        };
      };
      recyclarr = {
        image = "ghcr.io/recyclarr/recyclarr";
        autoStart = true;
        volumes = [
          "${vars.serviceConfigRoot}/recyclarr:/config"
        ];
        environment = {
          CRON_SCHEDULE = "@daily";
        };
      };
    };
  };
}
