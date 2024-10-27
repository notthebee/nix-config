{ config, lib, ... }:
let
  cfg = config.services.arr;
  directories = [ "${cfg.mounts.config}/prowlarr" ];
in
{
  options.services.arr.prowlarr = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable Prowlarr";
    };
  };
  config = lib.mkIf cfg.prowlarr.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        prowlarr = {
          image = "binhex/arch-prowlarr";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.prowlarr.rule=Host(`prowlarr.${cfg.baseDomainName}`)"
            "-l=traefik.http.services.prowlarr.loadbalancer.server.port=9696"
            "-l=homepage.group=Arr"
            "-l=homepage.name=Prowlarr"
            "-l=homepage.icon=prowlarr.svg"
            "-l=homepage.href=https://prowlarr.${cfg.baseDomainName}"
            "-l=homepage.description=Torrent indexer"
          ];
          volumes = [ "${cfg.mounts.config}/prowlarr:/config" ];
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
