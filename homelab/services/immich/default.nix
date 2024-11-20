{ config, lib, ... }:
let
  cfg = config.homelab.services.immich;
  directories = [
    "${cfg.mounts.config}"
    "${cfg.mounts.config}/postgresql"
    "${cfg.mounts.config}/postgresql/data"
    "${cfg.mounts.config}/config"
    "${cfg.mounts.config}/machine-learning"
    "${cfg.mounts.photos}"
    "${cfg.mounts.photos}/Immich"
  ];
in
{
  options.homelab.services.immich = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution";
    mounts.config = lib.mkOption {
      default = "${config.homelab.mounts.config}/immich";
      type = lib.types.path;
      description = ''
        Base path of the Immich config files
      '';
    };
    mounts.photos = lib.mkOption {
      default = "${config.homelab.mounts.merged}/Media/Photos";
      type = lib.types.path;
      description = ''
        Path to the Immich photos
      '';
    };
    baseDomainName = lib.mkOption {
      default = config.homelab.baseDomainName;
      type = lib.types.str;
      description = ''
        Base domain name to be used for Traefik reverse proxy (e.g. photos.baseDomainName)
      '';
    };
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Immich container as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        Group to run the Immich container as
      '';
    };
    timeZone = lib.mkOption {
      default = config.homelab.timeZone;
      type = lib.types.str;
      description = ''
        Time zone to be used inside the Jellyfin container
      '';
    };
    gpuAcceleration = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Enable GPU acceleration
      '';
    };
    dbCredentialsFile = lib.mkOption {
      default = "/dev/null";
      type = lib.types.path;
      description = "Path to the file containing the PostgreSQL credentials for Immich";
      example = lib.literalExpression ''
        pkgs.writeText "postgresql-credentials.txt '''
          POSTGRES_PASSWORD=immich
          DB_PASSWORD=immich
        '''
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;

    systemd.services = {
      podman-immich = {
        requires = [
          "podman-immich-redis.service"
          "podman-immich-postgres.service"
        ];
        after = [
          "podman-immich-redis.service"
          "podman-immich-postgres.service"
        ];
      };
      podman-immich-postgres = {
        requires = [ "podman-immich-redis.service" ];
        after = [ "podman-immich-redis.service" ];
      };
    };

    virtualisation.oci-containers.containers = {
      immich = {
        autoStart = true;
        image = "ghcr.io/imagegenius/immich:latest";
        volumes = [
          "${cfg.mounts.config}/config:/config"
          "${cfg.mounts.photos}/Immich:/photos"
          "${cfg.mounts.config}/machine-learning:/config/machine-learning"
        ];
        environmentFiles = [ cfg.dbCredentialsFile ];
        environment = {
          PUID = cfg.user;
          PGID = cfg.group;
          TZ = "Europe/Berlin";
          DB_HOSTNAME = "immich-postgres";
          DB_USERNAME = "immich";
          DB_DATABASE_NAME = "immich";
          REDIS_HOSTNAME = "immich-redis";
        };
        extraOptions = [
          "--pull=newer"
          "--network=container:immich-redis"
        ] ++ lib.lists.optional cfg.gpuAcceleration "--device=/dev/dri:/dev/dri";
      };

      immich-redis = {
        autoStart = true;
        image = "redis";
        extraOptions = [
          "--pull=newer"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.immich.rule=Host(`photos.${cfg.baseDomainName}`)"
          "-l=traefik.http.routers.immich.service=immich"
          "-l=traefik.http.services.immich.loadbalancer.server.port=8080"
        ];
      };

      immich-postgres = {
        autoStart = true;
        image = "tensorchord/pgvecto-rs:pg14-v0.2.1";
        volumes = [ "${cfg.mounts.config}/postgresql/data:/var/lib/postgresql/data" ];
        environmentFiles = [ cfg.dbCredentialsFile ];
        environment = {
          POSTGRES_USER = "immich";
          POSTGRES_DB = "immich";
        };
        extraOptions = [
          "--pull=newer"
          "--network=container:immich-redis"
        ];
      };
    };
  };
}
