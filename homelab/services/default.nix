{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homelab.services = {
    enable = lib.mkEnableOption "Containerized services for the homelab";
  };

  config = lib.mkIf config.homelab.services.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
      extraPackages = [ pkgs.zfs ];
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
    virtualisation.oci-containers = {
      backend = "podman";
    };

    networking.firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];
  };

  imports = [
    ./arr
    ./audiobookshelf
    ./calibre-web
    ./deluge
    ./traefik
    ./jellyfin
    ./paperless-ngx
    ./homepage
    ./immich
  ];
}
