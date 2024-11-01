{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.arr;
  directories = [ "${cfg.mounts.config}/sonarr" ];
in
{
  options.homelab.services.arr.sonarr = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable Sonarr";
    };
    apiKeyFile = lib.mkOption {
      default = true;
      type = lib.types.path;
      description = "Path to the file containing the Sonarr API key";
    };
  };

  config = lib.mkIf cfg.sonarr.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        sonarr = {
          image = "lscr.io/linuxserver/sonarr:develop";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.sonarr.rule=Host(`sonarr.${cfg.baseDomainName}`)"
            "-l=traefik.http.services.sonarr.loadbalancer.server.port=8989"
            "-l=homepage.group=Arr"
            "-l=homepage.name=Sonarr"
            "-l=homepage.icon=sonarr.svg"
            "-l=homepage.href=https://sonarr.${cfg.baseDomainName}"
            "-l=homepage.description=TV show tracker"
            "-l=homepage.widget.type=sonarr"
            "-l=homepage.widget.key={{HOMEPAGE_FILE_SONARR_KEY}}"
            "-l=homepage.widget.url=http://sonarr:8989"
          ];
          volumes = [
            "${cfg.mounts.downloads}:/downloads"
            "${cfg.mounts.tv}:/tv"
            "${cfg.mounts.config}/sonarr:/config"
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
