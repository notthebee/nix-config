{ config, libs, pkgs, utils, ... }: 
  with libs;
  with utils;
{
  
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
