{ config, lib, ... }:
let
  service = "sabnzbd";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkEnableOption {
      type = lib.types.path;
      default = "/var/lib/${service}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
    };
    services.caddy.virtualHosts."${service}.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8080
      '';
    };
  };

}
