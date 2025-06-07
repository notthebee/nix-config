{
  config,
  pkgs,
  lib,
  ...
}:
{

  environment.systemPackages = [ pkgs.tailscale ];

  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    extraUpFlags =
      let
        advertisedRoute =
          if lib.attrsets.hasAttrByPath [ config.networking.hostName ] config.homelab.networks.external then
            config.homelab.networks.external.${config.networking.hostName}.address
          else
            config.homelab.networks.local.lan.reservations.${config.networking.hostName}.Address;
      in
      [
        "--advertise-routes=${advertisedRoute}/32"
        "--reset"
      ];
  };
}
