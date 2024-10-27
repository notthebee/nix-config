{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.duckdns;
in
{
  options.services.duckdns = {
    enable = lib.mkEnableOption "DuckDNS Dynamic DNS Client";
    tokenFile = lib.mkOption {
      default = null;
      type = lib.types.path;
      description = ''
        The path to a file containing the token
        used to authenticate with DuckDNS.
      '';
    };

    domains = lib.mkOption {
      default = null;
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      example = [ "examplehost" ];
      description = ''
        The domain(s) to update in DuckDNS
        (without the .duckdns.org prefix)
      '';
    };

    domainsFile = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.path;
      example = lib.literalExpression ''
        pkgs.writeText "duckdns-domains.txt" '''
          examplehost
          examplehost2
          examplehost3
        '''
      '';
      description = ''
        The path to a file containing a
        newline-separated list of DuckDNS
        domain(s) to be updated
        (without the .duckdns.org prefix)
      '';
    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.domains != null || cfg.domainsFile != null;
        message = "Either services.duckdns.domains or services.duckdns.domainsFile has to be defined";
      }
      {
        assertion = !(cfg.domains != null && cfg.domainsFile != null);
        message = "services.duckdns.domains and services.duckdns.domainsFile can't both be defined at the same time";
      }
      {
        assertion = (cfg.tokenFile != null);
        message = "services.duckdns.tokenFile has to be defined";
      }
    ];
    systemd.services.duckdns = {
      description = "DuckDNS Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      path = [
        pkgs.gnused
        pkgs.systemd
        pkgs.curl
      ];
      serviceConfig = {
        Type = "simple";
        LoadCredential = [
          "DUCKDNS_TOKEN_FILE:${cfg.tokenFile}"
        ] ++ lib.optionals (cfg.domainsFile != null) [ "DUCKDNS_DOMAINS_FILE:${cfg.domainsFile}" ];
        DynamicUser = true;
      };
      script = ''
        export DUCKDNS_TOKEN=$(systemd-creds cat DUCKDNS_TOKEN_FILE)
        ${lib.optionalString (cfg.domains != null) ''
          export DUCKDNS_DOMAINS='${lib.strings.concatStringsSep "," cfg.domains}'
        ''}
        ${lib.optionalString (cfg.domainsFile != null) ''
          export DUCKDNS_DOMAINS=$(systemd-creds cat DUCKDNS_DOMAINS_FILE | sed -z 's/\n/,/g')
        ''}
        curl --no-progress-meter -k -K- <<< "url = \"https://www.duckdns.org/update?domains=$DUCKDNS_DOMAINS&token=$DUCKDNS_TOKEN&ip=\"" | grep -v "KO"
      '';
    };
  };

  meta.maintainers = with lib.maintainers; [ notthebee ];
}
