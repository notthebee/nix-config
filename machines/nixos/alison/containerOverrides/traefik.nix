{ config, lib, vars, networksLocal, ... }: let
internalIP = (lib.lists.findSingle (x: x.hostname == "${config.networking.hostName}") { ip-address = "${networksLocal.networks.lan.cidr}"; } "0.0.0.0" networksLocal.networks.lan.reservations).ip-address;
in
{
  virtualisation.oci-containers.containers.traefik.ports = lib.mkForce [
    "${internalIP}:443:443"
    "${internalIP}:80:80"
  ];
}
