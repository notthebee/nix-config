{ ... }:
{
  services.prometheus.exporters.zfs = {
    enable = true;
    openFirewall = false;
  };
}
