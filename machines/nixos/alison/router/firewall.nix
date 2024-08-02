{ lib, config, pkgs, vars, internalInterfaces, externalInterface, ... }:
{
  imports = [
    ../../../networksLocal.nix
  ];

  networking = {
    firewall = {
      enable = true;
      allowPing = true;

      trustedInterfaces = (lib.mapAttrsToList (_: val: val.interface) (lib.attrsets.filterAttrs (n: v: v.trusted) config.networks));
      interfaces."podman+".allowedUDPPorts = [ 53 ];
      # These ports will be opened *publicly*, via WAN
      allowedTCPPorts = lib.mkForce [ ];
      allowedUDPPorts = lib.mkForce [ ];
      interfaces."${config.networks.guest.interface}" = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };
      # Necessary to flush all non nixos-* tables
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
        lib.concatStrings [
          ''
            # Force all clients to use the router DNS
          ''
          (lib.concatMapStrings (x: "${x}\n") (lib.lists.flatten (lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) config.networks) (x:
            lib.lists.forEach [ "udp" "tcp" ] (y:
              ''
                iptables -t nat -A PREROUTING -i ${lib.attrsets.getAttrFromPath [x "interface"] config.networks} -p ${y} ! --source ${lib.attrsets.getAttrFromPath [x "cidr"] config.networks} ! --destination ${lib.attrsets.getAttrFromPath [x "cidr"] config.networks} --dport 53 -j DNAT --to ${lib.attrsets.getAttrFromPath [x "cidr"] config.networks}
              ''
            )))))
          ''
            # Block IOT devices from connecting to the internet
            ip46tables -A FORWARD -i ${config.networks.iot.interface} -o ${externalInterface} -j nixos-fw-log-refuse 

            # Isolate the guest network from the rest of the subnets

          ''
          (lib.concatMapStrings (x: "${x}\n") (lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) (lib.attrsets.filterAttrs (n: v: n != "guest") config.networks)) (x:
            ''
              ip46tables -A FORWARD -i ${config.networks.guest.interface} -o ${lib.attrsets.getAttrFromPath [x "interface"] config.networks}  -j nixos-fw-refuse
            ''
          )))
          ''
            # allow traffic with existing state
            ip46tables -A FORWARD -m state --state ESTABLISHED,RELATED -j nixos-fw-accept
            ip46tables -A INPUT -m state --state ESTABLISHED,RELATED -j nixos-fw-accept

            # Allow traffic on Podman 
            ip46tables -A INPUT -i podman0 -p tcp --dport 9001 -j nixos-fw-accept

            # allow Wireguard
            ip46tables -A INPUT -i ${externalInterface} -p udp --dport ${toString config.networking.wireguard.interfaces."${config.networks.wireguard.interface}".listenPort} -j nixos-fw-accept

            # block forwarding and inputs from external interface
            ip46tables -A FORWARD -i ${externalInterface} -j nixos-fw-log-refuse
            ip46tables -A INPUT -i ${externalInterface} -j nixos-fw-log-refuse

          ''
        ];
    };
  };
}
