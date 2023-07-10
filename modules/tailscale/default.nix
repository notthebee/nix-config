{ config, pkgs, ... }: {

  services.tailscale = { enable = true; };

  networking.firewall.allowedUDPPorts = [ 41641 ];

  # Let's make the tailscale binary available to all users
  environment.systemPackages = [ pkgs.tailscale ];
}
