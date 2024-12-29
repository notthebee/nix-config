{ config, lib, ... }:
let
  homelab = config.homelab;
  cfg = config.homelab.services.homeassistant;
in
{
  options.homelab.services.homeassistant = {
    enable = lib.mkEnableOption {
      description = "Enable Home Assistant";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d /var/lib/homeassistant 0775 ${homelab.user} ${homelab.group} - -" ];
    services.caddy.virtualHosts."home.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8123
      '';
    };
    virtualisation = {
      podman.enable = true;
      oci-containers = {
        containers = {
          homeassistant = {
            image = "homeassistant/home-assistant:stable";
            autoStart = true;
            extraOptions = [
              "--pull=newer"
              "--network=host"
            ];
            volumes = [
              "/var/lib/homeassistant:/config"
            ];
            environment = {
              TZ = homelab.timeZone;
              PUID = "994";
              PGID = "993";
            };
          };
        };
      };
    };
  };
}
