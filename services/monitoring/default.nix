{ config, vars, ... }:
{
# grafana configuration
  services.grafana = {
    enable = true;
    domain = "grafana.goose.party";
    port = 2342;
    addr = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ 2342 ];

  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "emily";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd"  ];
        port = 9002;
      };
    };
  };
}

