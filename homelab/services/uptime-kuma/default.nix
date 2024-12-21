{ config, lib, ... }:
let
  cfg = config.homelab.services.uptime-kuma;
  directories = [
    cfg.mounts.config
  ];
in
{
  options.homelab.services.uptime-kuma = {
    enable = lib.mkEnableOption "A fancy self-hosted monitoring tool";
    mounts.config = lib.mkOption {
      default = "${config.homelab.mounts.config}/uptime-kuma";
      type = lib.types.path;
      description = ''
        Base path of the Uptime Kuma config files
      '';
    };
    baseDomainName = lib.mkOption {
      default = config.homelab.baseDomainName;
      type = lib.types.str;
      description = ''
        Base domain name to be used for Traefik reverse proxy (e.g uptime.baseDomainName)
      '';
    };
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Uptime Kuma container as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        Group to run the Uptime Kuma container as
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        uptime-kuma = {
          image = "ghcr.io/louislam/uptime-kuma:nightly2";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.uptime-kuma.rule=Host(`uptime.${cfg.baseDomainName}`)"
            "-l=traefik.http.services.uptime-kuma.loadbalancer.server.port=3001"
            "-l=homepage.group=Services"
            "-l=homepage.name=Uptime Kuma"
            "-l=homepage.icon=uptimekuma.svg"
            "-l=homepage.href=https://uptime.${cfg.baseDomainName}"
            "-l=homepage.description=Service monitor"
          ];
          volumes = [
            "${cfg.mounts.config}:/app/data"
          ];
          environment = {
            PUID = cfg.user;
            GUID = cfg.group;
            UMASK = "002";
          };
        };
      };
    };
  };
}
