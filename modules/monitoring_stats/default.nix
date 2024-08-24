{ config, ... }:
{
  services.prometheus = {
    enable = false;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "tcpstat"
          "conntrack"
          "diskstats"
          "entropy"
          "filefd"
          "filesystem"
          "loadavg"
          "meminfo"
          "netdev"
          "netstat"
          "stat"
          "time"
          "vmstat"
          "logind"
          "interrupts"
          "ksmd"
        ];
        port = 9002;
      };
    };
  };
}
