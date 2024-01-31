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
        server = [ "127.0.0.1#10053" ];
        address = let
          ownAddress = config.networks.lan.cidr;
        in
        [
          (lib.concatStrings [
           (lib.concatMapStrings (x: "/" + x) [
            ("home." + vars.domainName)
            ownAddress
           ])
          ])
        ];
      };
    };
  };
}
