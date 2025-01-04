{
  config,
  pkgs,
  lib,
  ...
}:
let
  nordHighlight = builtins.toFile "nord.css" (builtins.readFile ./nord.css);
  nordUi = builtins.toFile "nord_ui.css" (builtins.readFile ./nord_ui.css);
  highlightJsNix = pkgs.fetchurl {
    url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/nix.min.js";
    hash = "sha256-j4dmtrr8qUODoICuOsgnj1ojTAmxbKe00mE5sfElC/I=";
  };
  highlightJs = pkgs.fetchurl {
    url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js";
    hash = "sha256-xKOZ3W9Ii8l6NUbjR2dHs+cUyZxXuUcxVMb7jSWbk4E=";
  };
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
      default = "microbin.png";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = with pkgs; [
      (final: prev: {
        microbin = prev.microbin.overrideAttrs (
          finalAttrs: previousAttrs: {
            postPatch = ''
              cp ${nordHighlight} templates/assets/highlight/highlight.min.css
              cp ${highlightJs} templates/assets/highlight/highlight.min.js
              cp ${highlightJsNix} templates/assets/highlight/nix.min.js
              echo "" >> templates/assets/water.css
              cat ${nordUi} >> templates/assets/water.css
              sed -i "s#<option value=\"auto\">#<option value=\"auto\" selected>#" templates/index.html
              sed -i "s#highlight.min.js\"></script>#highlight.min.js\"></script><script type=\"text/javascript\" src=\"{{ args.public_path_as_str() }}/static/highlight/nix.min.js\"></script>#" templates/upload.html
            '';
          }
        );
      })
    ];
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
