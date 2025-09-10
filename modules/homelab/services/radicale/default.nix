{ config, lib, ... }:
let
  cfg = config.homelab.services.radicale;
  homelab = config.homelab;
in
{
  options.homelab.services.radicale = {
    enable = lib.mkEnableOption "Free and Open-Source CalDAV and CardDAV Server";
    url = lib.mkOption {
      type = lib.types.str;
      default = "cal.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Radicale";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Free and Open-Source CalDAV and CardDAV Server";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "radicale.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
    passwordFile = lib.mkOption {
      description = "Path to Radicale user credentials";
      type = lib.types.path;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.radicale.serviceConfig.LoadCredential = "radicale.htpasswd:${cfg.passwordFile}";
    services.radicale = {
      enable = true;
      extraArgs = [
        "--auth-htpasswd-filename=%d/radicale.htpasswd"
        "--auth-htpasswd-encryption=plain"
      ];
      settings = {
        server = {
          hosts = [
            "127.0.0.1:5232"
          ];
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
        };

        auth = {
          type = "htpasswd";
        };
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${builtins.head config.services.radicale.settings.server.hosts}
      '';
    };
  };

}
