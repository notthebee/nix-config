{ config, pkgs, lib, ... }:
{
  imports = [
    ../../../networksLocal.nix
  ];
  networking.wireguard = {
    enable = true;
    interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      "${config.networks.wireguard.interface}" = {
       # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [ "${config.networks.wireguard.cidr}/24" ];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = 51820;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${lib.strings.removeSuffix ".1" config.networks.wireguard.cidr + ".0/24"} -o ${config.networking.nat.externalInterface} -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${lib.strings.removeSuffix ".1" config.networks.wireguard.cidr + ".0/24"} -o ${config.networking.nat.externalInterface} -j MASQUERADE
        '';

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        privateKeyFile = config.age.secrets.wireguardPrivateKeyAlison.path;

        peers = [
          { 
            name = "meredith";
            publicKey = "rAkXoiMoxwsKaZc4qIpoXWxD9HBCYjsAB33hPB7jBBg=";
            allowedIPs = [ (lib.strings.removeSuffix ".1" config.networks.wireguard.cidr + ".2/32") ];
          }
          {
            name = "iphone";
            publicKey = "6Nh1FrZLJBv7kb/jlR+rkCsWDoiSq9jpOQo68a6vr0Q=";
            allowedIPs = [ (lib.strings.removeSuffix ".1" config.networks.wireguard.cidr + ".3/32") ];
          }
        ];
      };
      };
    };


}
