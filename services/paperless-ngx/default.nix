{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/paperless"
"${vars.cacheArray}/Documents"
"${vars.cacheArray}/Documents/Paperless"
"${vars.cacheArray}/Documents/Paperless/Documents"
"${vars.cacheArray}/Documents/Paperless/Import"
"${vars.cacheArray}/Documents/Paperless/Export"
];
in
{

  systemd.services = {
  podman-paperless-redis = {
    requires = [ "podman-paperless.service" ];
    after = [ "podman-paperless.service" ];
  };
  };
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;

  networking.firewall.allowedTCPPorts = [ 
  8080 # WebDAV
  ];

  services.webdav = {
  enable = true;
  user = "share";
  group = "share";
  environmentFile = config.age.secrets.paperless.path;
  settings = {
    address = "0.0.0.0";
    port = 8080;
    scope = "${vars.cacheArray}/Documents/Paperless/Import";
    modify = true;
    auth = true;
    users = [
      {
        username = "notthebee";
        password = "{env}PASSWORD";
      }
    ];
  };
  };

  virtualisation.oci-containers = {
    containers = {
      paperless = {
        image = "ghcr.io/paperless-ngx/paperless-ngx";
        autoStart = true;
        extraOptions = [
          "--device=/dev/dri/renderD128:/dev/dri/renderD128"
          "--device=/dev/dri/card0:/dev/dri/card0"
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.paperless.rule=Host(`paperless.${vars.domainName}`)"
          "-l=traefik.http.services.paperless.loadbalancer.server.port=8000"
          "-l=homepage.group=Services"
          "-l=homepage.name=Paperless"
          "-l=homepage.icon=paperless.svg"
          "-l=homepage.href=https://paperless.${vars.domainName}"
          "-l=homepage.description=Digital document database"
          "-l=homepage.widget.type=paperlessngx"
          "-l=homepage.widget.key={{HOMEPAGE_VAR_PAPERLESS_TOKEN}}"
          "-l=homepage.widget.url=http://paperless:8000"
        ];
        volumes = [
          "${vars.cacheArray}/Documents/Paperless/Documents:/usr/src/paperless/media"
          "${vars.cacheArray}/Documents/Paperless/Import:/usr/src/paperless/consume"
          "${vars.cacheArray}/Documents/Paperless/Export:/usr/src/paperless/export"
          "${vars.serviceConfigRoot}/paperless/data:/usr/src/paperless/data"
        ];
        environmentFiles = [
          config.age.secrets.paperless.path
        ];
        environment = {
          PAPERLESS_REDIS = "redis://paperless-redis:6379";
          PAPERLESS_OCR_LANGUAGE = "deu";
          PAPERLESS_FILENAME_FORMAT = "{created}-{correspondent}-{title}";
          PAPERLESS_TIME_ZONE = "${vars.timeZone}";
          PAPERLESS_URL = "https://paperless.${vars.domainName}";
          PAPERLESS_ADMIN_USER = "notthebee";
          PAPERLESS_CONSUMER_POLLING = "1";
          PAPERLESS_SECRET_KEY = "changeme";
          USERMAP_UID = "994";
          UID = "994";
          GID = "9943";
          USERMAP_GID = "993";
        };
      };
      paperless-redis = {
        image = "redis";     
        autoStart = true;
        extraOptions = [
          "--network=container:paperless"
        ];
      };
};
};
}
