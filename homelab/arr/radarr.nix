{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.arr;
  directories = [ "${cfg.mounts.config}/radarr" ];
in
{
  options.homelab.services.arr.radarr = {
    enable = lib.mkOption {
      default = config.homelab.services.arr.enable;
      type = lib.types.bool;
      description = "Enable Radarr";
    };
    apiKeyFile = lib.mkOption {
      default = "/dev/null";
      type = lib.types.path;
      description = "Path to the file containing the Radarr API key";
    };
  };
  config = lib.mkIf cfg.radarr.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        radarr = {
          image = "lscr.io/linuxserver/radarr";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.radarr.rule=Host(`radarr.${cfg.baseDomainName}`)"
            "-l=traefik.http.services.radarr.loadbalancer.server.port=7878"
            "-l=homepage.group=Arr"
            "-l=homepage.name=Radarr"
            "-l=homepage.icon=radarr.svg"
            "-l=homepage.href=https://radarr.${cfg.baseDomainName}"
            "-l=homepage.description=Movie tracker"
            "-l=homepage.widget.type=radarr"
            "-l=homepage.widget.key={{HOMEPAGE_FILE_RADARR_KEY}}"
            "-l=homepage.widget.url=http://radarr:7878"
          ];
          volumes = [
            "${cfg.mounts.downloads}:/downloads"
            "${cfg.mounts.movies}:/movies"
            "${cfg.mounts.config}/radarr:/config"
          ];
          environment = {
            TZ = cfg.timeZone;
            PUID = cfg.user;
            GUID = cfg.group;
            UMASK = "002";
          };
        };
      };
    };
  };
}
