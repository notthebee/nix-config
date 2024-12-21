{ config, vars, ... }:
let
  directories = [
    "${vars.cacheArray}/Media/Nextcloud"
    "${vars.serviceConfigRoot}/nextcloud"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      nextloud-redis = {
        image = "redis";
        autoStart = true;
        extraOptions = [ "--network=container:nextcloud" ];
      };
      nextcloud-db = {
        image = "mariadb";
        autoStart = true;
        volumes = [
          "${vars.serviceConfigRoot}/nextcloud/mariadb:/var/lib/mysql"
        ];
        extraOptions = [
          "--pull=newer"
          "--network=container:nextcloud"
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
        image = "nextcloud:stable-fpm-alpine";
        autoStart = true;
        dependsOn = [
          "nextcloud-cloudflared"
          "nextcloud-db"
          "nextcloud-redis"
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
          "${vars.serviceConfigRoot}/nextcloud:/var/www/html"
          "${vars.cacheArray}/Nextcloud:/var/www/html/data"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
          NEXTCLOUD_ADMIN_USER = "notthebee";
          NEXTCLOUD_TRUSTED_DOMAINS = "cloud.${vars.domainName}";
          SMTP_HOST = config.email.smtpServer;
          MAIL_FROM_ADDRESS = config.email.fromAddress;
          SMTP_NAME = config.email.smtpUsername;
          SMTP_SECURE = "tls";
          MYSQL_HOST = "nextcloud-db";
          REDIS_HOST = "nextcloud-redis";
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
