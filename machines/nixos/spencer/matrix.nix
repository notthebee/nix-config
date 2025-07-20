{
  pkgs,
  config,
  ...
}:
let
  domain = "notthebe.ee";
  fqdn = "chat.${domain}";
  baseUrl = "https://${fqdn}";
  serverConfig."m.server" = "${fqdn}:443";
  clientConfig."m.homeserver".base_url = baseUrl;
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
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
    email = "moe@notthebe.ee";
    user = "deploy";
    group = "deploy";
    enable = true;
    virtualHosts = {
      "${domain}".extraConfig = ''
        respond /.well-known/matrix/server `${builtins.toJSON serverConfig}`
        respond /.well-known/matrix/client `${builtins.toJSON clientConfig}`
      '';
      "${fqdn}".extraConfig = ''
        @matrix path /_matrix/* /_matrix /_synapse/client/* /_synapse/client
        reverse_proxy @matrix http://[::1]:8008
        respond / 404
      '';
    };
  };
  services.matrix-synapse = {
    enable = true;
    extraConfigFiles = [
      config.age.secrets.matrixRegistrationSecret.path
    ];
    settings = {
      server_name = domain;
      public_baseurl = baseUrl;
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
}
