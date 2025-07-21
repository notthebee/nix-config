{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "ocis";
  cfg = config.homelab.services.${service};
  hl = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "cloud.${hl.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "OCIS";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Enterprise File Storage and Collaboration";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "owncloud.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
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
        ingress."${cfg.url}".service =
          "http://${config.services.ocis.address}:${toString config.services.ocis.port}";
      };
    };

    systemd.services.ocis.preStart = ''
      ${lib.getExe pkgs.ocis} init || true
    '';
    services.${service} = {
      enable = true;
      url = "https://${cfg.url}";
      environment =
        let
          cspFormat = pkgs.formats.yaml { };
          cspConfig = {
            directives = {
              child-src = [ "'self'" ];
              connect-src = [
                "'self'"
                "blob:"
                "https://${config.homelab.services.keycloak.url}"
              ];
              default-src = [ "'none'" ];
              font-src = [ "'self'" ];
              frame-ancestors = [ "'none'" ];
              frame-src = [
                "'self'"
                "blob:"
                "https://embed.diagrams.net"
              ];
              img-src = [
                "'self'"
                "data:"
                "blob:"
              ];
              manifest-src = [ "'self'" ];
              media-src = [ "'self'" ];
              object-src = [
                "'self'"
                "blob:"
              ];
              script-src = [
                "'self'"
                "'unsafe-inline'"
              ];
              style-src = [
                "'self'"
                "'unsafe-inline'"
              ];
            };
          };
        in
        {
          PROXY_AUTOPROVISION_ACCOUNTS = "true";
          PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
          OCIS_OIDC_ISSUER = "https://${hl.services.keycloak.url}/realms/master";
          PROXY_OIDC_REWRITE_WELLKNOWN = "true";
          WEB_OIDC_CLIENT_ID = "ocis";
          OCIS_LOG_LEVEL = "error";
          PROXY_TLS = "false";
          PROXY_USER_OIDC_CLAIM = "preferred_username";
          PROXY_USER_CS3_CLAIM = "username";
          OCIS_ADMIN_USER_ID = "";
          OCIS_INSECURE = "false";
          OCIS_EXCLUDE_RUN_SERVICES = "idp";
          GRAPH_ASSIGN_DEFAULT_USER_ROLE = "false";
          PROXY_CSP_CONFIG_FILE_LOCATION = toString (cspFormat.generate "csp.yaml" cspConfig);
          GRAPH_USERNAME_MATCH = "none";
          PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
        };
    };
  };
}
