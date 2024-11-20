{ config, lib, ... }:
let
  cfg = config.homelab.services.jellyfin;
  directories = [
    cfg.mounts.config
    cfg.mounts.tv
    cfg.mounts.movies
  ];
in
{
  options.homelab.services.jellyfin = {
    enable = lib.mkEnableOption "The Free Software Media System";
    mounts.config = lib.mkOption {
      default = "${config.homelab.mounts.config}/jellyfin";
      type = lib.types.path;
      description = ''
        Base path of the Jellyfin config files
      '';
    };
    mounts.tv = lib.mkOption {
      default = "${config.homelab.mounts.merged}/Media/TV";
      type = lib.types.path;
      description = ''
        Path to the Jellyfin TV shows
      '';
    };
    mounts.movies = lib.mkOption {
      default = "${config.homelab.mounts.merged}/Media/Movies";
      type = lib.types.path;
      description = ''
        Path to the Jellyfin movies
      '';
    };
    baseDomainName = lib.mkOption {
      default = config.homelab.baseDomainName;
      type = lib.types.str;
      description = ''
        Base domain name to be used for Traefik reverse proxy (e.g. jellyfin.baseDomainName)
      '';
    };
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Jellyfin container as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        Group to run the Jellyfin container as
      '';
    };
    timeZone = lib.mkOption {
      default = config.homelab.timeZone;
      type = lib.types.str;
      description = ''
        Time zone to be used inside the Jellyfin container
      '';
    };
    gpuAcceleration = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Enable GPU acceleration for video transcoding
      '';
    };
    apiKeyFile = lib.mkOption {
      default = "/dev/null";
      type = lib.types.path;
      description = "Path to the file containing the Jellyfin API key";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        jellyfin = {
          image = "lscr.io/linuxserver/jellyfin";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.jellyfin.rule=Host(`jellyfin.${cfg.baseDomainName}`)"
            "-l=traefik.http.services.jellyfin.loadbalancer.server.port=8096"
            "-l=homepage.group=Media"
            "-l=homepage.name=Jellyfin"
            "-l=homepage.icon=jellyfin.svg"
            "-l=homepage.href=https://jellyfin.${cfg.baseDomainName}"
            "-l=homepage.description=Media player"
            "-l=homepage.widget.type=jellyfin"
            "-l=homepage.widget.key={{HOMEPAGE_FILE_JELLYFIN_KEY}}"
            "-l=homepage.widget.url=http://jellyfin:8096"
            "-l=homepage.widget.enableBlocks=true"
          ] ++ lib.lists.optional cfg.gpuAcceleration "--device=/dev/dri:/dev/dri";
          volumes = [
            "${cfg.mounts.tv}:/data/tvshows"
            "${cfg.mounts.movies}:/data/movies"
            "${cfg.mounts.config}:/config"
          ];
          environment = {
            TZ = cfg.timeZone;
            PUID = cfg.user;
            GUID = cfg.group;
            UMASK = "002";
          };
        };
      };
    };
  };
}
