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
            (lib.lists.findSingle (
              x: x.hostname == config.networking.hostName
            ) false false config.homelab.networks.local.lan.reservations).ip-address;
      in
      [
        "--advertise-routes=${advertisedRoute}/32"
        "--reset"
      ];
  };
}
