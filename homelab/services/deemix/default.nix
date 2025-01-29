{ config, lib, ... }:
let
  service = "deemix";
  cfg = config.homelab.services.${service};
  hl = config.homelab;
in
{
  imports = [ ./service.nix ];
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    musicDir = lib.mkOption {
      type = lib.types.str;
      default = "${hl.mounts.fast}/Media/Music/Import";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${hl.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Deemix";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Deezer downloader";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "deemix.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Downloads";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      user = hl.user;
      group = hl.group;
      musicDir = cfg.musicDir;
      listenHost = "127.0.0.1";
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = hl.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.${service}.listenHost}:${
          toString config.services.${service}.listenPort
        }
      '';
    };
  };

}
