{
  lib,
  config,
  pkgs,
  ...
}:
let
  externalInterface = "wan0";
  networks = config.homelab.networks.local;
in
{
  networking = {
    firewall = {
      enable = true;
      allowPing = true;

      trustedInterfaces = (
        lib.mapAttrsToList (_: val: val.interface) (lib.attrsets.filterAttrs (n: v: v.trusted) networks)
      );
      interfaces."podman+".allowedUDPPorts = [ 53 ];
      # These ports will be opened *publicly*, via WAN
      allowedTCPPorts = lib.mkForce [ ];
      allowedUDPPorts = lib.mkForce [ ];
      interfaces."${networks.iot.interface}" = {
        allowedUDPPorts = [
          53
          67
        ];
      };
      interfaces."${networks.guest.interface}" = {
        allowedUDPPorts = [
          53
          67
        ];
        allowedTCPPorts = [ 53 ];
      };
      extraStopCommands = ''
        iptables-save | ${pkgs.gawk}/bin/awk '/^[*]/ { print $1 }
                       /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; }
                       /COMMIT/ { print $0; }' | iptables-restore

        ip6tables-save | ${pkgs.gawk}/bin/awk '/^[*]/ { print $1 }
                       /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; }
                       /COMMIT/ { print $0; }' | ip6tables-restore

        ${pkgs.podman}/bin/podman network reload -a
      '';

      extraCommands =
        let
          getInterface =
            x:
            lib.attrsets.getAttrFromPath [
              x
              "interface"
            ] networks;
          getCidr =
            x:
            lib.attrsets.getAttrFromPath [
              x
              "cidr"
              "v4"
            ] networks;
        in
        lib.concatStrings [
          ''
            # Block IOT devices from connecting to the internet
            ip46tables -A FORWARD -i ${networks.iot.interface} -o ${externalInterface} -j nixos-fw-log-refuse

            # Isolate the guest network from the rest of the subnets
            iptables -A FORWARD -i ${networks.guest.interface} ! -o ${externalInterface} -j nixos-fw-log-refuse
          ''
          ''
            # allow traffic with existing state
            ip46tables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j nixos-fw-accept
            ip46tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j nixos-fw-accept

            # allow Wireguard
            ip46tables -A INPUT -i ${externalInterface} -p udp --dport ${
              toString config.systemd.network.netdevs."50-wg0".wireguardConfig.ListenPort
            } -j nixos-fw-accept

            # IPv6 connectivity
          ''
          (lib.concatMapStrings (x: "${x}\n") (
            (lib.lists.forEach
              [
                "destination-unreachable"
                "packet-too-big"
                "time-exceeded"
                "parameter-problem"
                "echo-reply"
                "router-advertisement"
                "router-solicitation"
                "neighbor-solicitation"
                "neighbor-advertisement"
              ]
              (
                icmp-type:
                "ip6tables -A INPUT -i ${externalInterface} -p icmpv6 --icmpv6-type ${icmp-type} -j nixos-fw-accept"
              )
            )
          ))
          ''
            ip6tables -A INPUT -i ${externalInterface} -p udp --sport 547 --dport 546 -s fe80::/10 -j nixos-fw-accept


            # block forwarding and inputs from external interface
            ip46tables -A FORWARD -i ${externalInterface} -j nixos-fw-log-refuse
            ip46tables -A INPUT -i ${externalInterface} -j nixos-fw-log-refuse
          ''
        ];
    };
  };
}
