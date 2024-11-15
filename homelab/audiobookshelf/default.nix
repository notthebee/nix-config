{
  config,
  vars,
  lib,
  ...
}:
let
  cfg = config.homelab.services.audiobookshelf;
  directories = [
    cfg.mounts.base
    cfg.mounts.podcasts
    cfg.mounts.audiobooks
    cfg.mounts.config
    cfg.mounts.metadata
  ];
in
{
  options.homelab.services.audiobookshelf = {
    enable = lib.mkEnableOption "Self-hosted audiobook and podcast server";
    mounts.config = lib.mkOption {
      default = "${config.homelab.mounts.config}/audiobookshelf";
      type = lib.types.path;
      description = ''
        Path to Audiobookshelf configs
      '';
    };
    mounts.base = lib.mkOption {
      default = "${config.homelab.mounts.merged}/Media/Audiobookshelf";
      type = lib.types.path;
      description = ''
        Path to the audiobookshelf media files
      '';
    };

    mounts.audiobooks = lib.mkOption {
      default = "${cfg.mounts.base}/Audiobooks";
      type = lib.types.path;
      description = ''
        Path to the audiobooks folder
      '';
    };
    mounts.podcasts = lib.mkOption {
      default = "${cfg.mounts.base}/Podcasts";
      type = lib.types.path;
      description = ''
        Path to the podcasts folder
      '';
    };
    mounts.metadata = lib.mkOption {
      default = "${config.homelab.mounts.fast}/Media/Audiobookshelf/Metadata";
      type = lib.types.path;
      description = ''
        Path to the podcasts folder
      '';
    };
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Audiobookshelf as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        User to run the Audiobookshelf as
      '';
    };
    timeZone = lib.mkOption {
      default = config.homelab.timeZone;
      type = lib.types.str;
      description = ''
        Time zone to be used inside the Audiobookshelf container
      '';
    };
    baseDomainName = lib.mkOption {
      default = config.homelab.baseDomainName;
      type = lib.types.str;
      description = ''
        Base domain name to be used for Traefik reverse proxy (e.g. audiobooks.baseDomainName)
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${cfg.user} ${cfg.group} - -") directories;
    virtualisation.oci-containers = {
      containers = {
        audiobookshelf = {
          image = "ghcr.io/advplyr/audiobookshelf:latest";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=homepage.group=Media"
            "-l=homepage.name=Audiobookshelf"
            "-l=homepage.icon=audiobookshelf.svg"
            "-l=homepage.href=https://audiobooks.${vars.domainName}"
            "-l=homepage.description=Audiobook and podcast player"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.audiobookshelf.rule=Host(`audiobooks.${cfg.baseDomainName}`)"
            "-l=traefik.http.routers.audiobookshelf.service=audiobookshelf"
            "-l=traefik.http.services.audiobookshelf.loadbalancer.server.port=80"
          ];
          volumes = [
            "${cfg.mounts.audiobooks}:/audiobooks"
            "${cfg.mounts.podcasts}:/podcasts"
            "${cfg.mounts.config}:/config"
            "${cfg.mounts.metadata}:/metadata"
          ];
          environment = {
            TZ = cfg.timeZone;
            PUID = cfg.user;
            GUID = cfg.group;
          };
        };
      };
    };
  };
}
