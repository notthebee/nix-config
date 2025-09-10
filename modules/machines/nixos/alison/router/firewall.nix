{
  config,
  ...
}:
let
  externalInterface = "wan0";
  networks = config.homelab.networks.local;
  iot = networks.iot.interface;
  guest = networks.guest.interface;
  lan = networks.lan.interface;
  wgPort = toString config.systemd.network.netdevs."50-wg0".wireguardConfig.ListenPort;
in
{
  networking = {
    nftables = {
      enable = true;
      flushRuleset = false;
      tables = {
        nat = {
          family = "ip";
          content = ''
            chain prerouting {
                type nat hook prerouting priority filter; policy accept;
                # Intercept DNS queries and make sure they get redirected to the router's DNS
                iifname {"${guest}", "${iot}", "${lan}"} udp dport 53 counter redirect to 53
                iifname {"${guest}", "${iot}", "${lan}"} tcp dport 53 counter redirect to 53
              }

              chain postrouting {
                type nat hook postrouting priority 100; policy accept;
                oifname ${externalInterface} masquerade
              }
          '';
        };
        global = {
          family = "inet";
          content = ''
            chain inbound_world {
                # Enable ICMPv6 types necessary for DHCPv6
                ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, mld-listener-query, nd-router-solicit } accept
                # Allow port 546/udp for DHCPv6
                ip6 saddr fe80::/10 iifname ${externalInterface} udp sport 547 udp dport 546 accept

                # Allow Wireguard
                udp dport ${wgPort} accept

                counter drop
              }

              chain inbound_untrusted {
                icmp type echo-request limit rate 5/second accept
                ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, mld-listener-query, nd-router-solicit } accept

                # Allow DNS and DHCP on untrusted networks (iot, guest)
                udp dport 53 accept
                udp dport 546 accept
                tcp dport 53 accept
                udp dport 67 accept

                counter drop
              }

              chain inbound {
                type filter hook input priority 0; policy drop;

                # Allow traffic from established and related packets, drop invalid
                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname vmap { lo : accept, "podman*" : accept, wg0 : accept, ${externalInterface} : jump inbound_world, ${lan} : accept, ${guest} : jump inbound_untrusted, ${iot} : jump inbound_untrusted }
              }

              chain forward {
                type filter hook forward priority 0; policy drop;

                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname {"${lan}", "wg0", "podman*"} accept
                iifname ${guest} oifname ${externalInterface} accept

                counter drop
              }

              chain prerouting {
                type nat hook prerouting priority filter; policy accept;

              }
          '';
        };
      };
    };

    firewall.enable = false;
    nat.enable = false;
  };
}
