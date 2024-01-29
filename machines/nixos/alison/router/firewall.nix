{ ... }:
{
networking = {
  firewall = {
    enable = true;
    allowPing = true;
    extraStopCommands = ''
      iptables -P INPUT ACCEPT
      iptables -P FORWARD ACCEPT
      iptables -P OUTPUT ACCEPT
      iptables -t nat -F
      iptables -t mangle -F
      iptables -F
      iptables -X
    '';
    extraCommands =
      let
        dropPortNoLog = port:
        ''
        ip46tables -A nixos-fw -p tcp \
        --dport ${toString port} -j nixos-fw-refuse
        ip46tables -A nixos-fw -p udp \
        --dport ${toString port} -j nixos-fw-refuse
        '';

        dropPortIcmpLog =
          ''
          iptables -A nixos-fw -p icmp \
          -j LOG --log-prefix "iptables[icmp]: "
          ip6tables -A nixos-fw -p ipv6-icmp \
          -j LOG --log-prefix "iptables[icmp-v6]: "
          '';

          refusePortOnInterface = port: interface:
          ''
          ip46tables -A nixos-fw -i ${interface} -p tcp \
          --dport ${toString port} -j nixos-fw-log-refuse
          ip46tables -A nixos-fw -i ${interface} -p udp \
          --dport ${toString port} -j nixos-fw-log-refuse
          '';
          acceptPortOnInterface = port: interface:
          ''
          ip46tables -A nixos-fw -i ${interface} -p tcp \
          --dport ${toString port} -j nixos-fw-accept
          ip46tables -A nixos-fw -i ${interface} -p udp \
          --dport ${toString port} -j nixos-fw-accept
          '';
        # IPv6 flat forwarding. For ipv4, see nat.forwardPorts
        forwardPortToHost = port: interface: proto: host:
        ''
        ip6tables -A FORWARD -i ${interface} \
        -p ${proto} -d ${host} \
        --dport ${toString port} -j ACCEPT
        ip6tables -A nixos-fw -i ${interface} \
        -p ${proto} -d ${host} \
        --dport ${toString port} -j ACCEPT
        '';

        privatelyAcceptPort = port:
        lib.concatMapStrings
        (interface: acceptPortOnInterface port interface)
        internalInterfaces;

        publiclyRejectPort = port:
        refusePortOnInterface port externalInterface;

        allowPortOnlyPrivately = port:
        ''
        ${privatelyAcceptPort port}
        ${publiclyRejectPort port}
        '';
      in
      lib.concatStrings [
        (lib.concatMapStrings allowPortOnlyPrivately
        [
          67 # DHCP
          546 # DHCPv6
          547 # DHCPv6
          9100 # prometheus
          5201 # iperf
          53 # DNS
        ])
        (lib.concatMapStrings dropPortNoLog
        [
          23 # Common from public internet
          143 # Common from public internet
          139 # From RT AP
          515 # From RT AP
          9100 # From RT AP
        ])
        (dropPortIcmpLog)
          (lib.concatMapStrings (x: "${x}\n")
          (lib.lists.flatten (lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) config.networks) (x:
          lib.lists.forEach [ "udp" "tcp" ] (y:
          ''
          iptables -t nat -A PREROUTING -i ${lib.attrsets.getAttrFromPath [x "interface"] config.networks} -p ${y} ! --source ${lib.attrsets.getAttrFromPath [x "cidr"] config.networks} ! --destination ${lib.attrsets.getAttrFromPath [x "cidr"] config.networks} --dport 53 -j DNAT --to ${lib.attrsets.getAttrFromPath [x "cidr"] config.networks}
          ''
          )))))
          ''
          # allow from trusted interfaces
          ip46tables -A FORWARD -m state --state NEW -i ${config.networks.lan.interface} -o ${externalInterface} -j ACCEPT
          ip46tables -A FORWARD -m state --state NEW -i ${config.networks.guest.interface} -o ${externalInterface} -j ACCEPT
          ip46tables -A FORWARD -m state --state NEW -i ${config.networks.app.interface} -o ${externalInterface} -j ACCEPT
          # allow traffic with existing state
          ip46tables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
          ip46tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
          # block forwarding from external interface
          ip46tables -A FORWARD -i ${externalInterface} -j DROP
          ip46tables -A INPUT -i ${externalInterface} -j DROP
          ''
        ];
        allowedUDPPorts = [];
      };
};
}
