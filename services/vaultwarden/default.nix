{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/vaultwarden"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      vaultwarden = {
        image = "vaultwarden/server:latest";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.vaultwarden.rule=Host(`pass.${vars.domainName}`)"
          "-l=traefik.http.services.vaultwarden.loadbalancer.server.port=80"
          "-l=homepage.group=Services"
          "-l=homepage.name=Vaultwarden"
          "-l=homepage.icon=bitwarden.svg"
          "-l=homepage.href=https://pass.${vars.domainName}"
          "-l=homepage.description=Password manager"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/vaultwarden:/data"
        ];
        environment = {
          DOMAIN = "https://pass.${vars.domainName}";
          WEBSOCKET_ENABLED = "true";
        };
      };
    };
};
}
