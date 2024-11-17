{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homelab.services.homepage;
  directories = [
    "${cfg.mounts.config}"
    "${cfg.mounts.config}/config"
  ];
  settingsFormat = pkgs.formats.yaml { };
  homepageSettings = {
    docker = settingsFormat.generate "docker.yaml" (import ./docker.nix);
    services = pkgs.writeTextFile {
      name = "services.yaml";
      text = builtins.readFile ./services.yaml;
    };
    settings = pkgs.writeTextFile {
      name = "settings.yaml";
      text = builtins.readFile ./settings.yaml;
    };
    bookmarks = settingsFormat.generate "bookmarks.yaml" (import ./bookmarks.nix);
    widgets = pkgs.writeTextFile {
      name = "widgets.yaml";
      text = builtins.readFile ./widgets.yaml;
    };
  };
  homepageCustomCss = pkgs.writeTextFile {
    name = "custom.css";
    text = builtins.readFile ./custom.css;
  };
in
{
  options.homelab.services.homepage = {
    enable = lib.mkEnableOption "A modern, fully static, fast, secure, fully proxied, highly customizable application dashboard";
    mounts.config = lib.mkOption {
      default = "${config.homelab.mounts.config}/homelab";
      type = lib.types.path;
      description = ''
        Base path of the Homepage config files
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
        Base domain name to be used for Traefik reverse proxy (e.g. baseDomainName)
      '';
    };
    integrations.glances = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Enable Glances integration
      '';
    };
    integrations.sonarr = lib.mkOption {
      default = config.homelab.services.arr.sonarr.enable;
      type = lib.types.bool;
      description = ''
        Enable Sonarr integration
      '';
    };
    integrations.radarr = lib.mkOption {
      default = config.homelab.services.arr.radarr.enable;
      type = lib.types.bool;
      description = ''
        Enable Radarr integration
      '';
    };
    integrations.jellyfin = lib.mkOption {
      default = config.homelab.services.jellyfin.enable;
      type = lib.types.bool;
      description = ''
        Enable Jellyfin integration
      '';
    };
    integrations.paperless = lib.mkOption {
      default = config.homelab.services.paperless.enable;
      type = lib.types.bool;
      description = ''
        Enable Paperless integration
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ glances ];
    networking.firewall.allowedTCPPorts = [ 61208 ];
    systemd.services.glances = {
      description = "Glances";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.glances}/bin/glances -w";
        Type = "simple";
      };
    };
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
    virtualisation.oci-containers = {
      containers = {
        homepage = {
          image = "ghcr.io/gethomepage/homepage:latest";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=traefik.enable=true"
            "-l=traefik.http.routers.home.rule=Host(`${cfg.baseDomainName}`)"
            "-l=traefik.http.services.home.loadbalancer.server.port=3000"
          ];
          volumes =
            [
              "${cfg.mounts.config}/config:/app/config"
              "${homepageSettings.docker}:/app/config/docker.yaml"
              "${homepageSettings.bookmarks}:/app/config/bookmarks.yaml"
              "${homepageSettings.services}:/app/config/services.yaml"
              "${homepageSettings.settings}:/app/config/settings.yaml"
              "${homepageSettings.widgets}:/app/config/widgets.yaml"
              "${homepageCustomCss}:/app/config/custom.css"
              "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
            ]
            ++ lib.lists.optional cfg.integrations.sonarr "${config.homelab.services.arr.sonarr.apiKeyFile}:/app/config/sonarr.key"
            ++ lib.lists.optional cfg.integrations.radarr "${config.homelab.services.arr.radarr.apiKeyFile}:/app/config/radarr.key"
            ++ lib.lists.optional cfg.integrations.jellyfin "${config.homelab.services.jellyfin.apiKeyFile}:/app/config/jellyfin.key"
            ++ lib.lists.optional cfg.integrations.paperless "${config.homelab.services.paperless.apiKeyFile}:/app/config/paperless.key";
          environment =
            {
              TZ = cfg.timeZone;
            }
            // lib.attrsets.optionalAttrs cfg.integrations.sonarr {
              HOMEPAGE_FILE_SONARR_KEY = "/app/config/sonarr.key";
            }
            // lib.attrsets.optionalAttrs cfg.integrations.radarr {
              HOMEPAGE_FILE_RADARR_KEY = "/app/config/radarr.key";
            }
            // lib.attrsets.optionalAttrs cfg.integrations.jellyfin {
              HOMEPAGE_FILE_JELLYFIN_KEY = "/app/config/jellyfin.key";
            }
            // lib.attrsets.optionalAttrs cfg.integrations.paperless {
              HOMEPAGE_FILE_PAPERLESS_KEY = "/app/config/paperless.key";
            };
        };
      };
    };
  };
}
