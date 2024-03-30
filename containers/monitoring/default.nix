{ config, vars, ... }:
{
# grafana configuration
networking.firewall.allowedTCPPorts = [ 
  9100
  ];


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
        port = 9100;
      };
    };
  };
}

