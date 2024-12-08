{ config }:
let
  domain = "uptime.goose.party";
in
{
  services.uptime-kuma = {
    enable = true;
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
  };
  virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;
    root = "/dev/null";
    locations."/".proxyPass =
      "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";
    proxyWebsockets = true;
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    certs."${domain}".email = "moe@notthebe.ee";
  };
}
