{
  config,
  vars,
  lib,
  ...
}:
let
  cfg = config.homelab.services.calibre;
  directories = [
    cfg.mounts.books
    cfg.mounts.config
  ];
in
{
  options.homelab.services.calibre = {
    enable = lib.mkEnableOption "Self-hosted Calibre frontend and server";
    mounts.config = lib.mkOption {
      default = "${config.homelab.mounts.config}/calibre-web";
      type = lib.types.path;
      description = ''
        Path to Calibre-web configs
      '';
    };
    mounts.library = lib.mkOption {
      default = "${config.homelab.mounts.fast}/Media/Calibre";
      type = lib.types.path;
      description = ''
        Path to the Calibre library
      '';
    };

    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run Calibre-Web as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        User to run Calibre-Web as
      '';
    };
    timeZone = lib.mkOption {
      default = config.homelab.timeZone;
      type = lib.types.str;
      description = ''
        Time zone to be used inside the Calibre-Web container
      '';
    };
    baseDomainName = lib.mkOption {
      default = config.homelab.baseDomainName;
      type = lib.types.str;
      description = ''
        Base domain name to be used for Traefik reverse proxy (e.g. calibre.baseDomainName)
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        calibre-web = {
          image = "lscr.io/linuxserver/calibre-web:latest";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=homepage.group=Media"
            "-l=homepage.name=Calibre-Web"
            "-l=homepage.icon=calibre-web.svg"
            "-l=homepage.href=https://calibre.${vars.domainName}"
            "-l=homepage.description=eBook management frontend"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.calibre.rule=Host(`calibre.${cfg.baseDomainName}`)"
            "-l=traefik.http.routers.calibre.service=calibre"
            "-l=traefik.http.services.calibre.loadbalancer.server.port=8083"
          ];
          volumes = [
            "${cfg.mounts.config}:/config"
            "${cfg.mounts.library}:/library"
          ];
          environment = {
            TZ = cfg.timeZone;
            PUID = cfg.user;
            GUID = cfg.group;
          };
        };
      };
    };
  };
}
