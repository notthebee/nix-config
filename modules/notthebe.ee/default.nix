{
systemd.tmpfiles.rules = ["d /var/www/notthebe.ee 0775 deploy deploy - -"];

services.nginx = {

  enable = true;

  recommendedGzipSettings = true;
  recommendedOptimisation = true;
  recommendedProxySettings = true;
  recommendedTlsSettings = true;

  # Only allow PFS-enabled ciphers with AES256
  sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
  
  commonHttpConfig = ''
    # Add HSTS header with preloading to HTTPS requests.
    # Adding this header to HTTP requests is discouraged
    map $scheme $hsts_header {
        https   "max-age=31536000; includeSubdomains; preload";
    }
    add_header Strict-Transport-Security $hsts_header;

    # Enable CSP for your services.
    #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

    # Minimize information leaked to other domains
    add_header 'Referrer-Policy' 'origin-when-cross-origin';

    # Disable embedding as a frame
    add_header X-Frame-Options DENY;

    # Prevent injection of code in other mime types (XSS Attacks)
    add_header X-Content-Type-Options nosniff;

    # Enable XSS protection of the browser.
    # May be unnecessary when CSP is configured properly (see above)
    add_header X-XSS-Protection "1; mode=block";

    # This might create errors
    proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
  '';

  virtualHosts."notthebe.ee" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/notthebe.ee";
};
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
