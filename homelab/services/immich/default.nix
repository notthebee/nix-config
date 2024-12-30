{ config, lib, ... }:
let
  cfg = config.homelab.services.immich;
  homelab = config.homelab;
in
{
  options.homelab.services.immich = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution";
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Immich container as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        Group to run the Immich container as
      '';
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.homelab.mounts.fast}/Photos/Immich";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 immich ${homelab.group} - -" ];
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    services.immich = {
      group = homelab.group;
      enable = true;
      port = 2283;
      mediaLocation = "${cfg.mediaDir}";
    };
    services.caddy.virtualHosts."photos.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString config.services.immich.port}
      '';
    };
  };
}
