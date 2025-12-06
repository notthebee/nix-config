{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "nextcloud";
  cfg = config.homelab.services.${service};
  hl = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${hl.mounts.fast}/Media/Nextcloud";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "cloud.${hl.baseDomain}";
    };
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "phpfpm-nextcloud"
      ];
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Nextcloud";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Enterprise File Storage and Collaboration";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "nextcloud.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
    cloudflared.credentialsFile = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "cloudflare-credentials.json" '''
        {"AccountTag":"secret"."TunnelSecret":"secret","TunnelID":"secret"}
        '''
      '';
    };
    cloudflared.tunnelId = lib.mkOption {
      type = lib.types.str;
      example = "00000000-0000-0000-0000-000000000000";
    };
    admin.username = lib.mkOption {
      type = lib.types.str;
      example = "admin";
    };
    admin.passwordFile = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "nc-admin-password" '''
        super-secret-password
        '''
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = lib.lists.forEach [ "" ] (
      x: "d ${cfg.dataDir}/${x} 0775 nextcloud ${hl.group} - -"
    );
    services.nginx.virtualHosts."nix-nextcloud".listen = [
      {
        addr = "127.0.0.1";
        port = 8009;
      }
    ];
    services.cloudflared = {
      enable = true;
      tunnels.${cfg.cloudflared.tunnelId} = {
        credentialsFile = cfg.cloudflared.credentialsFile;
        default = "http_status:404";
        ingress."${cfg.url}".service = "http://127.0.0.1:8009";
      };
    };

    fileSystems."${config.services.nextcloud.home}/data" = {
      device = cfg.dataDir;
      fsType = "none";
      options = [
        "bind"
      ];
    };
    services.nextcloud = {
      enable = true;
      hostName = "nix-nextcloud";
      package = pkgs.nextcloud32;
      database.createLocally = true;
      configureRedis = true;
      maxUploadSize = "16G";
      https = true;
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit
          calendar
          contacts
          mail
          notes
          tasks
          ;

      };

      settings = {
        overwriteprotocol = "https";
        default_phone_region = "DE";
      };
      config = {
        dbtype = "pgsql";
        adminuser = cfg.admin.username;
        adminpassFile = cfg.admin.passwordFile;
      };
    };

  };
}
