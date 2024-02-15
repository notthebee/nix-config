{ config, pkgs, lib, ... }:
with lib;

let
cfg = config.services.duckdns;
in
{
  options = {
    services.duckdns = {
      enable = mkEnableOption (lib.mdDoc "DuckDNS Dynamic DNS Client");

      tokenFile = mkOption {
        default = null;
        type = types.str;
        description = lib.mdDoc ''
          The path to a file containing the token
          used to authenticate with DuckDNS.
          '';
      };

      domain = mkOption {
        default = null;
        example = "example";
        type = types.nullOr types.str;
        description = lib.mdDoc ''
          The record to update in DuckDNS
          '';
      };

      domainFile = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = lib.mdDoc ''
          The path to a file containing the DuckDNS domain
          '';
      };

    };
  };

  config = mkIf cfg.enable {
    systemd.services.duckdns = {
      description = "DuckDNS Dynamic DNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*:0/5";
      serviceConfig = {
        Type = "simple";
        LoadCredential = [
          (lib.optional (cfg.tokenFile != null) "DUCKDNS_TOKEN_FILE:${cfg.tokenFile}")
          (lib.optional (cfg.domainFile != null) "DUCKDNS_DOMAIN_FILE:${cfg.domainFile}")
        ];
        DynamicUser = true;
      };
      script = ''
        export DUCKDNS_TOKEN=$(${pkgs.systemd}/bin/systemd-creds cat DUCKDNS_TOKEN_FILE)
        ${optionalString (cfg.domain != null) ''
          export DUCKDNS_DOMAIN="${cfg.domain})"
        ''}
        ${optionalString (cfg.domainFile != null) ''
          export DUCKDNS_DOMAIN=$(${pkgs.systemd}/bin/systemd-creds cat DUCKDNS_DOMAIN_FILE)
        ''}
      echo url="https://www.duckdns.org/update?domains=$DUCKDNS_DOMAIN&token=$DUCKDNS_TOKEN&ip=" | ${pkgs.curl}/bin/curl -k -K -
        '';
    };
  };
}
