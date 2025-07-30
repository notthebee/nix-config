{ config, ... }:
let
  domain = "notthebe.ee";
in
{
  services.plausible = {
    enable = true;
    server = {
      baseUrl = "https://numbers.${domain}";
      secretKeybaseFile = config.age.secrets.plausibleSecretKeybaseFile.path;
    };
  };
  services.caddy = {
    email = "moe@notthebe.ee";
    user = "deploy";
    group = "deploy";
    enable = true;
    virtualHosts = {
      "numbers.${domain}".extraConfig = ''
        reverse_proxy http://${config.services.plausible.server.listenAddress}:${toString config.services.plausible.server.port}
      '';
    };
  };
}
