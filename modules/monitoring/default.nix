{ config, lib, networksLocal, ... }:
{
  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ((lib.lists.findSingle (x: x.hostname == "emily") { ip-address = "${networksLocal.networks.lan.cidr}"; } "0.0.0.0" networksLocal.networks.lan.reservations).ip-address + ":" + toString config.services.prometheus.exporters.node.port)
          ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        port = 9002;
      };
    };
  };
}
