{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/jellyfin"
"${vars.mainArray}/Media/TV"
"${vars.mainArray}/Media/Movies"
];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      jellyfin = {
        image = "lscr.io/linuxserver/jellyfin";
        autoStart = true;
        extraOptions = [
          "--device=/dev/dri/renderD128:/dev/dri/renderD128"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.jellyfin.rule=Host(`jellyfin.${vars.domainName}`)"
          "-l=traefik.http.services.jellyfin.loadbalancer.server.port=8096"
          "-l=homepage.group=Media"
          "-l=homepage.name=Jellyfin"
          "-l=homepage.icon=jellyfin.svg"
          "-l=homepage.href=https://jellyfin.${vars.domainName}"
          "-l=homepage.description=Media player"
          "-l=homepage.widget.type=jellyfin"
          "-l=homepage.widget.key={{HOMEPAGE_FILE_JELLYFIN_KEY}}"
          "-l=homepage.widget.url=http://jellyfin:8096"
          "-l=homepage.widget.enableBlocks=true"
        ];
        volumes = [
          "${vars.mainArray}/Media/TV:/data/tvshows"
          "${vars.mainArray}/Media/Movies:/data/movies"
          "${vars.serviceConfigRoot}/jellyfin:/config"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          UMASK = "002";
          GUID = "993";
          DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel";
          ROC_ENABLE_PRE_VEGA = "1";
        };
      };
    };
};
}
