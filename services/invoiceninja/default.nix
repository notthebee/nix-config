{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/invoiceninja"
"${vars.serviceConfigRoot}/invoiceninja/config"
"${vars.serviceConfigRoot}/invoiceninja/mariadb"
];
  in
{
systemd.services.podman-invoiceninja-db = {
  requires = [ "podman-invoiceninja.service" ];
  after = [ "podman-invoiceninja.service" ];
};
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;

  virtualisation.oci-containers = {
    containers = {
      invoiceninja = {
        image = "maihai/invoiceninja_v5";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.invoiceninja.rule=Host(`invoice.${vars.domainName}`)"
          "-l=homepage.group=Services"
          "-l=homepage.name=InvoiceNinja"
          "-l=homepage.icon=invoiceninja-light.png"
          "-l=homepage.href=https://invoice.${vars.domainName}"
          "-l=homepage.description=Invoicing software"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/invoiceninja/config:/config"
        ];
        environmentFiles = [
          config.age.secrets.invoiceNinja.path
        ];
        environment = {
          DB_HOST = "invoiceninja-db";
          DB_PORT = "3306";
          DB_DATABASE = "invoiceninja";
          DB_USERNAME = "invoiceninja";
          APP_URL = "https://invoice.goose.party";
          MAIL_MAILER = "smtp";
          MAIL_PORT = "465";
          MAIL_ENCRYPTION = "tls";
          MAIL_HOST = config.email.smtpServer;
          MAIL_USERNAME = config.email.smtpUsername;
          MAIL_FROM_NAME = "Wolfgang's Channel";
          MEMORY_LIMIT = "512M";
          REQUIRE_HTTPS = "false";
          SSL_HOSTNAME = "invoiceninja";
        };

      };
      invoiceninja-db = {
        image = "mariadb";     
        autoStart = true;
        volumes = [
          "${vars.serviceConfigRoot}/invoiceninja/mariadb:/var/lib/mysql"
        ];
        extraOptions = [
          "--network=container:invoiceninja"
        ];
        environmentFiles = [
          config.age.secrets.invoiceNinja.path
        ];
        environment = {
          MARIADB_DATABASE = "invoiceninja";
          MARIADB_RANDOM_ROOT_PASSWORD = "yes";
          MARIADB_USER = "invoiceninja";
        };
      };
    };
};
}
