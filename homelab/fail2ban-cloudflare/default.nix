{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.fail2ban-cloudflare;
in
{
  options.services.fail2ban-cloudflare = {
    enable = lib.mkEnableOption {
      description = "Enable fail2ban-cloudflare";
    };
    apiKeyFile = lib.mkOption {
      description = "File containing your API key, scoped to Firewall Rules: Edit";
      type = lib.types.str;
      example = lib.literalExpression ''
        Authorization: Bearer Qj06My1wXJEzcW46QCyjFbSMgVtwIGfX63Ki3NOj79o=
        '''
      '';
    };
    zoneId = lib.mkOption {
      type = lib.types.str;
    };
    jails = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            serviceName = lib.mkOption {
              example = "vaultwarden";
              type = lib.types.str;
            };
            failRegex = lib.mkOption {
              type = lib.types.str;
              example = "Login failed from IP: <HOST>";
            };
            ignoreRegex = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
            maxRetry = lib.mkOption {
              type = lib.types.int;
              default = 3;
            };
          };
        }
      );
    };
  };
  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      extraPackages = [
        pkgs.curl
        pkgs.jq
      ];

      jails = lib.attrsets.mapAttrs (name: value: {
        settings = {
          bantime = "30d";
          findtime = "1h";
          enabled = true;
          backend = "systemd";
          journalmatch = "_SYSTEMD_UNIT=${value.serviceName}.service";
          port = "http,https";
          filter = "${name}";
          maxretry = 3;
          action = "cloudflare-token-agenix";
        };
      }) cfg.jails;
    };

    environment.etc = lib.attrsets.mergeAttrsList [
      (lib.attrsets.mapAttrs' (
        name: value:
        (lib.nameValuePair ("fail2ban/filter.d/${name}.conf") ({
          text = ''
            [Definition]
            failregex = ${value.failRegex}
            ignoreregex = ${value.ignoreRegex}
          '';
        }))
      ) cfg.jails)
      {
        "fail2ban/action.d/cloudflare-token-agenix.conf".text =
          let
            notes = "Fail2Ban on ${config.networking.hostName}";
            cfapi = "https://api.cloudflare.com/client/v4/zones/${cfg.zoneId}/firewall/access_rules/rules";
          in
          ''
            [Definition]
            actionstart =
            actionstop =
            actioncheck =
            actionunban = id=$(curl -s -X GET "${cfapi}" \
                -H @${cfg.apiKeyFile} -H "Content-Type: application/json" \
                    | jq -r '.result[] | select(.notes == "${notes}" and .configuration.target == "ip" and .configuration.value == "<ip>") | .id')
                if [ -z "$id" ]; then echo "id for <ip> cannot be found"; exit 0; fi; \
                curl -s -X DELETE "${cfapi}/$id" \
                    -H @${cfg.apiKeyFile} -H "Content-Type: application/json" \
                    --data '{"cascade": "none"}'
            actionban = curl -X POST "${cfapi}" -H @${cfg.apiKeyFile} -H "Content-Type: application/json" --data '{"mode":"block","configuration":{"target":"ip","value":"<ip>"},"notes":"${notes}"}'
            [Init]
            name = cloudflare-token-agenix
          '';
      }
    ];
  };
}
