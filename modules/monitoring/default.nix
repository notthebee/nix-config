{ config, lib, ... }:
let
  networks = config.homelab.networks.local;
in
{
  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              (
                (lib.lists.findSingle (x: x.hostname == "emily") {
                  ip-address = "${networks.lan.cidr}";
                } "0.0.0.0" networks.lan.reservations).ip-address
                + ":"
                + toString config.services.prometheus.exporters.node.port
              )
            ];
          }
        ];
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
