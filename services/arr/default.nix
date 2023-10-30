{ inputs, lib, config, pkgs, vars, ... }:
  let
directories = [
"${vars.serviceConfigRoot}/sonarr"
"${vars.serviceConfigRoot}/radarr"
"${vars.serviceConfigRoot}/prowlarr"
"${vars.serviceConfigRoot}/recyclarr"
"${vars.serviceConfigRoot}/booksonic"
"${vars.mainArray}/Media/Downloads"
"${vars.mainArray}/Media/TV"
"${vars.mainArray}/Media/Movies"
"${vars.mainArray}/Media/Audiobooks"
];
  in
  {

system.activationScripts.recyclarr_configure = ''
    sed=${pkgs.gnused}/bin/sed
    configFile=${vars.serviceConfigRoot}/recyclarr/recyclarr.yml
    sonarr="${inputs.recyclarr-configs}/sonarr/web-2160p-v4.yml"
    sonarrApiKey=$(cat "${config.age.secrets.sonarrApiKey.path}")
    radarr="${inputs.recyclarr-configs}/radarr/remux-web-2160p.yml"
    radarrApiKey=$(cat "${config.age.secrets.radarrApiKey.path}")

    cat $sonarr > $configFile
    $sed -i"" "s/Put your API key here/$sonarrApiKey/g" $configFile
    $sed -i"" "s/Put your Sonarr URL here/https:\/\/sonarr.${vars.domainName}/g" $configFile

    printf "\n" >> ${vars.serviceConfigRoot}/recyclarr/recyclarr.yml
    cat $radarr >> ${vars.serviceConfigRoot}/recyclarr/recyclarr.yml
    $sed -i"" "s/Put your API key here/$radarrApiKey/g" $configFile
    $sed -i"" "s/Put your Radarr URL here/https:\/\/radarr.${vars.domainName}/g" $configFile

    '';
  
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      sonarr = {
        image = "lscr.io/linuxserver/sonarr:develop";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.sonarr.rule=Host(`sonarr.${vars.domainName}`)"
          "-l=traefik.http.services.sonarr.loadbalancer.server.port=8989"
        ];
        volumes = [
            "${vars.mainArray}/Media/Downloads:/downloads"
            "${vars.mainArray}/Media/TV:/tv"
            "${vars.serviceConfigRoot}/sonarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          UMASK = "002";
        };
      };
      prowlarr = {
        image = "binhex/arch-prowlarr";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.prowlarr.rule=Host(`prowlarr.${vars.domainName}`)"
          "-l=traefik.http.services.prowlarr.loadbalancer.server.port=9696"
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
      radarr = {
        image = "lscr.io/linuxserver/radarr";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.radarr.rule=Host(`radarr.${vars.domainName}`)"
          "-l=traefik.http.services.radarr.loadbalancer.server.port=7878"
        ];
        volumes = [
            "${vars.mainArray}/Media/Downloads:/downloads"
            "${vars.mainArray}/Media/Movies:/movies"
            "${vars.serviceConfigRoot}/radarr:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          UMASK = "002";
        };
      };
      booksonic = {
        image = "lscr.io/linuxserver/booksonic-air";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.booksonic.rule=Host(`booksonic.${vars.domainName}`)"
          "-l=traefik.http.services.booksonic.loadbalancer.server.port=4040"
        ];
        volumes = [
            "${vars.mainArray}/Media/Audiobooks:/audiobooks"
            "${vars.serviceConfigRoot}/booksonic:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          CONTEXT_PATH = "/";
          UMASK = "002";
        };
      };
      recyclarr = {
        image = "ghcr.io/recyclarr/recyclarr";
        user = "994:993";
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
