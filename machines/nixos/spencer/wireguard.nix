{
  config,
  pkgs,
  lib,
  ...
}:
let
  wg = config.homelab.networks.external.spencer-wireguard;
  wgBase = lib.strings.removeSuffix ".1" wg.gateway;
in
{
  networking.nat.enable = true;
  networking.nat.externalInterface = config.networking.defaultGateway.interface;
  networking.nat.internalInterfaces = [ wg.interface ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "${wg.gateway}/24" ];
      listenPort = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${wgBase}.0/24 -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${wgBase}.0/24 -o eth0 -j MASQUERADE
      '';

      privateKeyFile = config.age.secrets.wireguardPrivateKeySpencer.path;

      peers = [
        {
          name = "emily";
          publicKey = "npTrLwAIJZ3m4XqdmQpP/KIi0C6urjBQHoCuA1vOOTc=";
          allowedIPs = [ "${wgBase}.2/32" ];
        }
        {
          name = "meredith";
          publicKey = "qbSQWspWHmucDmU/BsrXpcVF+txPETo4c74/tGkE4C0=";
          allowedIPs = [ "${wgBase}.3/32" ];
        }
      ];
    };
  };

}
