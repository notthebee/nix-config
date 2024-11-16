{
  config,
  pkgs,
  lib,
  ...
}:
let
  networks = config.homelab.networks.local;
in
{
  networking.wireguard = {
    enable = true;
    interfaces = {
      "${networks.wireguard.interface}" = {
        ips = [ "${networks.wireguard.cidr}/24" ];

        listenPort = 51820;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${
            lib.strings.removeSuffix ".1" networks.wireguard.cidr + ".0/24"
          } -o ${config.networking.nat.externalInterface} -j MASQUERADE
        '';

        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${
            lib.strings.removeSuffix ".1" networks.wireguard.cidr + ".0/24"
          } -o ${config.networking.nat.externalInterface} -j MASQUERADE
        '';

        privateKeyFile = config.age.secrets.wireguardPrivateKeyAlison.path;

        peers = [
          {
            name = "meredith";
            publicKey = "rAkXoiMoxwsKaZc4qIpoXWxD9HBCYjsAB33hPB7jBBg=";
            allowedIPs = [ (lib.strings.removeSuffix ".1" networks.wireguard.cidr + ".2/32") ];
          }
          {
            name = "iphone";
            publicKey = "6Nh1FrZLJBv7kb/jlR+rkCsWDoiSq9jpOQo68a6vr0Q=";
            allowedIPs = [ (lib.strings.removeSuffix ".1" networks.wireguard.cidr + ".3/32") ];
          }
        ];
      };
    };
  };

}
