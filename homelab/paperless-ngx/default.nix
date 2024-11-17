{ config, lib, ... }:
let
  cfg = config.homelab.services.paperless;
  directories = [
    cfg.mounts.config
    cfg.mounts.documents
    "${cfg.mounts.documents}/Paperless"
    "${cfg.mounts.documents}/Paperless/Documents"
    "${cfg.mounts.documents}/Paperless/Import"
    "${cfg.mounts.documents}/Paperless/Export"
  ];
in
{
  options.homelab.services.paperless = {
    enable = lib.mkEnableOption "Open-source document management system";
    mounts.config = lib.mkOption {
      default = "${config.homelab.mounts.config}/paperless";
      type = lib.types.path;
      description = ''
        Base path of the Paperless config files
      '';
    };
    mounts.documents = lib.mkOption {
      default = "${config.homelab.mounts.fast}/Documents";
      type = lib.types.path;
      description = ''
        Path to the Jellyfin TV shows
      '';
    };
    baseDomainName = lib.mkOption {
      default = config.homelab.baseDomainName;
      type = lib.types.str;
      description = ''
        Base domain name to be used for Traefik reverse proxy (e.g. paperless.baseDomainName)
      '';
    };
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Paperless container as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        Group to run the Paperless container as
      '';
    };
    timeZone = lib.mkOption {
      default = config.homelab.timeZone;
      type = lib.types.str;
      description = ''
        Time zone to be used inside the Paperless container
      '';
    };
    apiKeyFile = lib.mkOption {
      default = "/dev/null";
      type = lib.types.path;
      description = "Path to the Paperless API key file for Homepage";
    };
    webdav.enable = lib.mkOption {
      default = cfg.enable;
      type = lib.types.bool;
      description = "Enable WebDAV endpoint";
    };
    webdav.port = lib.mkOption {
      default = 8080;
      type = lib.types.port;
      description = "WebDAV port";
    };
    webdav.user = lib.mkOption {
      default = cfg.adminUser;
      type = lib.types.str;
      description = "WebDAV login user";
    };
    adminUser = lib.mkOption {
      default = null;
      type = lib.types.str;
      description = ''
        Login and admin user for Paperless
      '';
    };
    secretsFile = lib.mkOption {
      default = "/dev/null";
      type = lib.types.path;
      description = "Path to the file containing the Paperless secret variables";
      example = lib.literalExpression ''
        pkgs.writeText "paperless-secrets" '''
          PAPERLESS_ADMIN_PASSWORD=Tb9DIct7O3u55XJQtebt
          PAPERLESS_SECRET_KEY=BztptdurbRGUSFXSUrzoiHfJin1K1gqGGCmaPLcV
          PASSWORD=WshYtuu9KDmgi5zjrgjK
        '''
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services = {
      podman-paperless-redis = {
        requires = [ "podman-paperless.service" ];
        after = [ "podman-paperless.service" ];
      };
    };
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;

    virtualisation.oci-containers = {
      containers = {
        paperless = {
          image = "ghcr.io/paperless-ngx/paperless-ngx";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "--device=/dev/dri:/dev/dri"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.paperless.rule=Host(`paperless.${cfg.baseDomainName}`)"
            "-l=traefik.http.services.paperless.loadbalancer.server.port=8000"
            "-l=homepage.group=Services"
            "-l=homepage.name=Paperless"
            "-l=homepage.icon=paperless.svg"
            "-l=homepage.href=https://paperless.${cfg.baseDomainName}"
            "-l=homepage.description=Digital document database"
            "-l=homepage.widget.type=paperlessngx"
            "-l=homepage.widget.key={{HOMEPAGE_VAR_PAPERLESS_TOKEN}}"
            "-l=homepage.widget.url=http://paperless:8000"
          ];
          volumes = [
            "${cfg.mounts.documents}/Paperless/Documents:/usr/src/paperless/media"
            "${cfg.mounts.documents}/Paperless/Import:/usr/src/paperless/consume"
            "${cfg.mounts.documents}/Paperless/Export:/usr/src/paperless/export"
            "${cfg.mounts.config}/data:/usr/src/paperless/data"
          ];
          environmentFiles = [ config.age.secrets.paperless.path ];
          environment = {
            PAPERLESS_REDIS = "redis://paperless-redis:6379";
            PAPERLESS_OCR_LANGUAGE = "deu";
            PAPERLESS_FILENAME_FORMAT = "{created}-{correspondent}-{title}";
            PAPERLESS_TIME_ZONE = "${cfg.timeZone}";
            PAPERLESS_URL = "https://paperless.${cfg.baseDomainName}";
            PAPERLESS_ADMIN_USER = cfg.adminUser;
            PAPERLESS_CONSUMER_POLLING = "1";
            PAPERLESS_SECRET_KEY = "changeme";
            USERMAP_UID = cfg.user;
            UID = cfg.user;
            GID = cfg.group;
            USERMAP_GID = cfg.group;
          };
        };
        paperless-redis = {
          image = "redis";
          autoStart = true;
          extraOptions = [ "--network=container:paperless" ];
        };
      };
    };
    networking.firewall.allowedTCPPorts = [ cfg.webdav.port ];

    services.webdav = {
      enable = true;
      user = "share";
      group = "share";
      environmentFile = cfg.secretsFile;
      settings = {
        address = "0.0.0.0";
        port = cfg.webdav.port;
        scope = "${cfg.mounts.documents}/Paperless/Import";
        modify = true;
        auth = true;
        users = [
          {
            username = cfg.webdav.user;
            password = "{env}PASSWORD";
          }
        ];
      };
    };
  };
}
