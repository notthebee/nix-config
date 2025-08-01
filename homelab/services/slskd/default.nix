{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "slskd";
  hl = config.homelab;
  cfg = hl.services.${service};
  ns = hl.services.wireguard-netns.namespace;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    downloadDir = lib.mkOption {
      type = lib.types.str;
      default = "${hl.mounts.fast}/Media/Music/Library";
    };
    incompleteDownloadDir = lib.mkOption {
      type = lib.types.str;
      default = "${hl.mounts.fast}/Media/Music/Import.tmp";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "slskd.${hl.baseDomain}";
    };
    beetsConfigFile = lib.mkOption {
      type = lib.types.path;
    };
    environmentFile = lib.mkOption {
      description = "File with slskd credentials";
      type = lib.types.path;
      example = lib.literalExpression ''
        pkgs.writeText "slskd-env" '''
          SLSKD_PASSWORD=slskd
          SLSKD_USERNAME=slskd
          SLSKD_JWT=secret
        '''
      '';
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "slskd";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Web-based Soulseek client";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "slskd.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Downloads";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${hl.user} ${hl.group} - -") [
      cfg.downloadDir
      cfg.incompleteDownloadDir
    ];
    services.${service} = {
      enable = true;
      user = hl.user;
      group = hl.group;
      environmentFile = cfg.environmentFile;
      domain = null;
      settings = {
        directories = {
          downloads = cfg.downloadDir;
          incomplete = cfg.incompleteDownloadDir;
        };
        shares = {
          directories = [ cfg.downloadDir ];
          filters = [
            "\.ini$"
            "Thumbs.db$"
            "\.DS_Store$"
          ];
        };
      };
    };
    systemd.sockets = lib.mkIf hl.services.wireguard-netns.enable {
      "slskd-web-proxy" = {
        enable = true;
        description = "Socket for Proxy to slskd WebUI";
        listenStreams = [ (toString config.services.${service}.settings.web.port) ];
        wantedBy = [ "sockets.target" ];
      };
    };
    systemd.services = lib.mkIf hl.services.wireguard-netns.enable {
      slskd = {
        bindsTo = [ "netns@${ns}.service" ];
        environment = {
          DOTNET_USE_POLLING_FILE_WATCHER = "true";
        };
        requires = [
          "network-online.target"
          "${ns}.service"
        ];
        serviceConfig.NetworkNamespacePath = [ "/var/run/netns/${ns}" ];
      };
      "slskd-web-proxy" = {
        enable = true;
        description = "Proxy to slskd WebUI in Network Namespace";
        requires = [
          "slskd.service"
          "slskd-web-proxy.socket"
        ];
        after = [
          "slskd.service"
          "slskd-web-proxy.socket"
        ];
        unitConfig = {
          JoinsNamespaceOf = "slskd.service";
        };
        serviceConfig = {
          User = config.services.slskd.user;
          Group = config.services.slskd.group;
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${
            toString config.services.${service}.settings.web.port
          }";
          PrivateNetwork = "yes";
        };
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = hl.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.${service}.settings.web.port}
      '';
    };
  };
}
