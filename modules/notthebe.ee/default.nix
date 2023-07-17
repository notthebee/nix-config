{
systemd.tmpfiles.rules = ["d /var/www/notthebe.ee 0775 deploy deploy - -"];

services.nginx.enable = true;
services.nginx.virtualHosts."notthebe.ee" = {
    addSSL = true;
    enableACME = true;
    root = "/var/www/notthebe.ee";
};

users.groups = {
  deploy = {};
};
users.users.deploy = {
  isNormalUser = true;
  home = "/var/www/notthebe.ee";
  group = "deploy";
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWW1IHfAeAzDEQ6lun+dgl0Ble8fVT5+R7uoeobtLvn notthebee@meredith"
  ];
};

networking.firewall.allowedTCPPorts = [ 80 443 ];

security.acme = {
  acceptTerms = true;
  certs."notthebe.ee".email = "moe@notthebe.ee";
};
}
