{
  pkgs,
  lib,
  config,
  ...
}:
let
  service = "matrix";
  cfg = config.homelab.services.${service};
  hl = config.homelab;
in
{
  options.homelab.services.matrix = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "chat.${hl.baseDomain}";
    };
    registrationSecretFile = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "matrix-registration-secret.txt" '''
          foobar
        '''
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.matrix-synapse = {
      isSystemUser = true;
      createHome = true;
      group = "matrix-synapse";
    };
    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
      '';
    };
    services.caddy = {
      virtualHosts =
        let
          serverConfig."m.server" = "${cfg.url}:443";
          clientConfig."m.homeserver".base_url = hl.baseDomain;
        in
        {
          "${hl.baseDomain}".extraConfig = ''
            respond /.well-known/matrix/server `${builtins.toJSON serverConfig}`
            respond /.well-known/matrix/client `${builtins.toJSON clientConfig}`
          '';
          "${cfg.url}" = {
            useACMEHost = hl.baseDomain;
            extraConfig = ''
              @matrix path /_matrix/* /_matrix /_synapse/client/* /_synapse/client
              reverse_proxy @matrix http://[::1]:8008
              respond / 404
            '';
          };
        };
    };
    services.matrix-synapse = {
      enable = true;
      extraConfigFiles = [
        cfg.registrationSecretFile
      ];
      settings = {
        server_name = hl.baseDomain;
        public_baseurl = "https://${cfg.url}";
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "::1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                ];
                compress = true;
              }
            ];
          }
        ];
        secondary_directory_servers = [
          "matrix.org"
        ];
      };
    };
  };
}
