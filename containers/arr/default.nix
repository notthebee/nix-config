{ config, lib, ... }:
let
  cfg = config.services.arr;
  directories = [
    cfg.mounts.config
    cfg.mounts.tv
    cfg.mounts.movies
    cfg.mounts.downloads
  ];
in
{
  options.services.arr = {
    enable = lib.mkEnableOption "The Arr stack (Prowlarr, Sonarr, Radarr and Recyclarr)";
    mounts.config = lib.mkOption {
      default = "/var/opt/arr";
      type = lib.types.path;
      description = ''
        Base path of the Arr stack config files
      '';
    };
    mounts.tv = lib.mkOption {
      default = lib.types.null;
      type = lib.types.path;
      description = ''
        Path to the Sonarr TV shows
      '';
    };
    mounts.movies = lib.mkOption {
      default = lib.types.null;
      type = lib.types.path;
      description = ''
        Path to the Radarr movies
      '';
    };
    mounts.downloads = lib.mkOption {
      default = lib.types.null;
      type = lib.types.path;
      description = ''
        Media downloads path to grab files from
      '';
    };
    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the Arr stack as
      '';
      apply = old: builtins.toString config.users.users."${old}".uid;
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the Arr stack as
      '';
      apply = old: builtins.toString config.users.groups."${old}".gid;
    };
    timeZone = lib.mkOption {
      default = "Europe/Berlin";
      type = lib.types.str;
      description = ''
        Time zone to be used inside the Arr containers
      '';
    };
    baseDomainName = lib.mkOption {
      default = null;
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
  ];
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
  };
}
