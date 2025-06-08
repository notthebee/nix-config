{ lib, config, ... }:
let
  networks = config.homelab.networks.local;
  internalIPs = (
    lib.lists.remove null (
      lib.lists.flatten (
        lib.mapAttrsToList (_: val: [
          val.cidr.v4
          val.cidr.v6
        ]) networks
      )
    )
  );
in
{
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = internalIPs ++ [
          "127.0.0.1"
          "::1"
        ];
        port = "53";
        do-ip4 = true;
        do-udp = true;
        do-tcp = true;
        do-ip6 = true;
        prefer-ip6 = true;
        use-caps-for-id = false;
        edns-buffer-size = 1232;
        prefetch = true;
        num-threads = 1;
        so-rcvbuf = "1m";
        qname-minimisation = true;
        access-control = [
          "0.0.0.0/0 allow"
          "::/0 allow"
        ];
      };
    };
  };
}
