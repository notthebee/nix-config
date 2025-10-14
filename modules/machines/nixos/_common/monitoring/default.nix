{ ... }:
{
  services.prometheus.exporters = {
    systemd = {
      enable = true;
      openFirewall = false;
    };
    node = {
      enable = true;
      openFirewall = false;
    };
    smartctl = {
      enable = true;
      openFirewall = false;
    };
  };
}
