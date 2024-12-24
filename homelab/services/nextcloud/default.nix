{ config, vars, ... }:
let
  directories = [
    "${vars.cacheArray}/Media/Nextcloud"
    "${vars.serviceConfigRoot}/nextcloud"
    "${vars.serviceConfigRoot}/nextcloud/config"
    "${vars.serviceConfigRoot}/nextcloud/mariadb"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      nextcloud-redis = {
        image = "redis";
        autoStart = true;
        dependsOn = [
          "nextcloud-cloudflared"
        ];
        extraOptions = [ "--network=container:nextcloud-cloudflared" ];
      };
      nextcloud-db = {
        image = "mariadb";
        autoStart = true;
        dependsOn = [
          "nextcloud-cloudflared"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/nextcloud/mariadb:/var/lib/mysql"
        ];
        extraOptions = [
          "--pull=newer"
          "--network=container:nextcloud-cloudflared"
        ];
        environmentFiles = [
          config.age.secrets.nextcloud.path
        ];
        environment = {
          MYSQL_DATABASE = "nextcloud";
          MYSQL_RANDOM_ROOT_PASSWORD = "yes";
        };
      };
      nextcloud = {
        image = "lscr.io/linuxserver/nextcloud:latest";
        autoStart = true;
        dependsOn = [
          "nextcloud-cloudflared"
        ];
        environmentFiles = [
          config.age.secrets.nextcloud.path
        ];
        extraOptions = [
          "--pull=newer"
          "--network=container:nextcloud-cloudflared"
          "-l=homepage.group=Services"
          "-l=homepage.name=Nextcloud"
          "-l=homepage.icon=nextcloud.svg"
          "-l=homepage.href=https://cloud.${vars.domainName}"
          "-l=homepage.description=Personal cloud"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/nextcloud/config:/config"
          "${vars.cacheArray}/Media/Nextcloud:/data"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          PGID = "993";
        };
      };
      nextcloud-cloudflared = {
        image = "cloudflare/cloudflared:latest";
        autoStart = true;
        cmd = [
          "tunnel"
          "--no-autoupdate"
          "run"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
        };
        environmentFiles = [
          config.age.secrets.nextcloudCloudflared.path
        ];
        extraOptions = [
          "--pull=newer"
        ];
      };
    };
  };
}
