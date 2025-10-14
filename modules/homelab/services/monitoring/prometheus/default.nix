{
  config,
  lib,
  ...
}:
let
  service = "prometheus";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
  prometheusUrl = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "prometheus.${homelab.baseDomain}";
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
    };
    scrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Prometheus";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Monitoring system & time series database";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "prometheus.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Observability";
    };
  };
  config = lib.mkIf cfg.enable {
    services.grafana = {
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = prometheusUrl;
            isDefault = true;
            editable = false;
          }
        ];
      };
    };
    services.prometheus = {
      enable = true;
      listenAddress = cfg.listenAddress;
      port = cfg.port;
      globalConfig.scrape_interval = "10s"; # "1m"
      scrapeConfigs = cfg.scrapeTargets;
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy ${prometheusUrl}
      '';
    };
  };

}
