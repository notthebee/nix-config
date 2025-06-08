{
  lib,
  config,
  pkgs,
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
      ruleset = ''
          table ip nat {
            chain prerouting {
              type nat hook prerouting priority filter; policy accept;
            }

            chain postrouting {
              type nat hook postrouting priority 100; policy accept;
              oifname ${externalInterface} masquerade
            }
          }
        table inet global {
          chain inbound_world {
            ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, mld-listener-query, nd-router-solicit } accept
            ip6 saddr fe80::/10 iifname ${externalInterface} udp sport 547 udp dport 546 accept
            udp dport ${wgPort} accept
            counter drop
          }

          chain inbound_untrusted {
            icmp type echo-request limit rate 5/second accept
            udp dport 53 accept
            tcp dport 53 accept
            udp dport 67 accept
            counter drop
          }

          chain inbound {
            type filter hook input priority 0; policy drop;

            # Allow traffic from established and related packets, drop invalid
            ct state vmap { established : accept, related : accept, invalid : drop }

            iifname vmap { lo : accept, ${externalInterface} : jump inbound_world, ${lan} : accept, ${guest}: jump inbound_untrusted, ${iot}: jump inbound_untrusted }
          }

          chain forward {
            type filter hook forward priority 0; policy drop;

            ct state vmap { established : accept, related : accept, invalid : drop }

            iifname ${lan} accept
            iifname ${guest} oifname ${externalInterface} accept
          }

          chain prerouting {
            type nat hook prerouting priority filter; policy accept;
            iifname {"${guest}", "${iot}", "${lan}"} udp dport 53 counter redirect to 53
            iifname {"${guest}", "${iot}", "${lan}"} tcp dport 53 counter redirect to 53
          }
        }
      '';
      enable = true;
    };

    firewall.enable = false;
    nat.enable = false;
  };
}
