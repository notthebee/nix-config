{ config, lib, ... }:
let
  cfg = config.homelab.services.arr;
  directories = [
    cfg.mounts.config
    cfg.mounts.tv
    cfg.mounts.movies
    cfg.mounts.downloads
  ];
in
{
  options.homelab.services.arr = {
    enable = lib.mkEnableOption "The Arr stack (Prowlarr, Sonarr, Radarr and Recyclarr)";
    mounts.config = lib.mkOption {
      default = config.homelab.mounts.config;
      type = lib.types.path;
      description = ''
        Base path of the Arr stack config files
      '';
    };
    mounts.tv = lib.mkOption {
      default = "${config.homelab.mounts.merged}/Media/TV";
      type = lib.types.path;
      description = ''
        Path to the Sonarr TV shows
      '';
    };
    mounts.movies = lib.mkOption {
      default = "${config.homelab.mounts.merged}/Media/Movies";
      type = lib.types.path;
      description = ''
        Path to the Radarr movies
      '';
    };
    mounts.downloads = lib.mkOption {
      default = "${config.homelab.mounts.merged}/Media/Downloads";
      type = lib.types.path;
      description = ''
        Media downloads path to grab files from
      '';
    };
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Arr stack as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        Group to run the Arr stack as
      '';
    };
    timeZone = lib.mkOption {
      default = config.homelab.timeZone;
      type = lib.types.str;
      description = ''
        Time zone to be used inside the Arr containers
      '';
    };
    baseDomainName = lib.mkOption {
      default = config.homelab.baseDomainName;
      type = lib.types.str;
      description = ''
        Base domain name to be used for Traefik reverse proxy (e.g. sonarr.baseDomainName)
      '';
    };

  };
  imports = [
    ./prowlarr.nix
    ./radarr.nix
    ./recyclarr.nix
    ./sonarr.nix
    ./bazarr.nix
  ];
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
  };
}
