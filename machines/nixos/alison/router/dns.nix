{ lib, config, pkgs, vars, ... }:
{
  services = {
    https-dns-proxy = {
      enable = true;
      port = 10053;
      extraArgs = [
        "-vvv"
      ];
    };
    dnsmasq = {
      enable = true;
      settings = {
        cache-size = 10000;
        server = [ "127.0.0.1#10053" ];
        address = let
          ownAddress = config.networks.lan.cidr;
          subdomains = [ "home" "ccu" "grafana" "prometheus" "deconz" "mqtt" ];
        in
        lib.lists.forEach subdomains (x:
          (lib.concatStrings [
           (lib.concatMapStrings (x: "/" + x) [
            ("${x}." + vars.domainName)
            ownAddress
           ])
          ]));
      };
    };
  };
}
