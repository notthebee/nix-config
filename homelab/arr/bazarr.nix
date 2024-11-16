{ config, lib, ... }:
let
  cfg = config.homelab.services.arr;
  directories = [ "${cfg.mounts.config}/bazarr" ];
in
{
  options.homelab.services.arr.bazarr = {
    enable = lib.mkOption {
      default = config.homelab.services.arr.enable;
      type = lib.types.bool;
      description = "Enable Bazarr";
    };
  };
  config = lib.mkIf cfg.bazarr.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        bazarr = {
          image = "lscr.io/linuxserver/bazarr";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.bazarr.rule=Host(`bazarr.${cfg.baseDomainName}`)"
            "-l=homepage.group=Arr"
            "-l=homepage.name=bazarr"
            "-l=homepage.icon=bazarr.svg"
            "-l=homepage.href=https://bazarr.${cfg.baseDomainName}"
            "-l=homepage.description=Subtitle manager"
          ];
          volumes = [
            "${cfg.mounts.movies}:/movies"
            "${cfg.mounts.tv}:/tv"
            "${cfg.mounts.config}/bazarr:/config"
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
