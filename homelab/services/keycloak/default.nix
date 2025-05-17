{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "keycloak";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "login.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Keycloak";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Open Source Identity and Access Management";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "keycloak.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
    dbPasswordFile = lib.mkOption {
      type = lib.types.path;
    };
    cloudflared.credentialsFile = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "cloudflare-credentials.json" '''
        {"AccountTag":"secret"."TunnelSecret":"secret","TunnelID":"secret"}
        '''
      '';
    };
    cloudflared.tunnelId = lib.mkOption {
      type = lib.types.str;
      example = "00000000-0000-0000-0000-000000000000";
    };
  };
  config = lib.mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels.${cfg.cloudflared.tunnelId} = {
        credentialsFile = cfg.cloudflared.credentialsFile;
        default = "http_status:404";
        ingress."${cfg.url}".service = "http://127.0.0.1:${
          toString config.services.${service}.settings.http-port
        }";
      };
    };

    environment.systemPackages = [
      pkgs.keycloak
      pkgs.custom_keycloak_themes.notthebee
    ];
    nixpkgs.overlays = [
      (final: prev: {
        custom_keycloak_themes = {
          notthebee = pkgs.callPackage ./theme.nix { };
        };
        custom_keycloak_plugins = {
          keycloak_spi_trusted_device = pkgs.callPackage ./trusted-device.nix { };
        };
      })
    ];

    services.${service} = {
      enable = true;
      initialAdminPassword = "schneke123";
      database.passwordFile = cfg.dbPasswordFile;
      themes = {
        notthebee = pkgs.custom_keycloak_themes.notthebee;
      };
      plugins = [ pkgs.custom_keycloak_plugins.keycloak_spi_trusted_device ];
      settings = {
        spi-theme-static-max-age = "-1";
        spi-theme-cache-themes = false;
        spi-theme-cache-templates = false;
        http-port = 8821;
        hostname = cfg.url;
        hostname-strict = false;
        hostname-strict-https = false;
        proxy-headers = "xforwarded";
        http-enabled = true;
      };
    };
  };

}
