{ config, lib, ... }:
let
  service = "microbin";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/microbin";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "bin.${homelab.baseDomain}";
    };
    passwordFile = lib.mkOption {
      default = "";
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "microbin-secret.txt" '''
          MICROBIN_ADMIN_USERNAME
          MICROBIN_ADMIN_PASSWORD
          MICROBIN_UPLOADER_PASSWORD
        '''
      '';
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
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Microbin";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "A minimal pastebin";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "microbin.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
  };
  config = lib.mkIf cfg.enable {
    services = {
      ${service} =
        {
          enable = true;
          settings = {
            MICROBIN_WIDE = true;
            MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = 2048;
            MICROBIN_PUBLIC_PATH = "https://${cfg.url}/";
            MICROBIN_BIND = "127.0.0.1";
            MICROBIN_PORT = 8069;
            MICROBIN_HIDE_LOGO = true;
            MICROBIN_HIGHLIGHTSYNTAX = true;
            MICROBIN_HIDE_HEADER = true;
            MICROBIN_HIDE_FOOTER = true;
          };
        }
        // lib.attrsets.optionalAttrs (cfg.passwordFile != "") {
          passwordFile = cfg.passwordFile;
        };
      cloudflared = {
        enable = true;
        tunnels.${cfg.cloudflared.tunnelId} = {
          credentialsFile = cfg.cloudflared.credentialsFile;
          default = "http_status:404";
          ingress."${cfg.url}".service =
            "http://${config.services.microbin.settings.MICROBIN_BIND}:${toString config.services.microbin.settings.MICROBIN_PORT}";
        };
      };
    };
  };

}
