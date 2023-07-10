{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/dashy"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      dashy = {
        image = "lissy93/dashy:latest";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.dashy.rule=Host(`${vars.domainName}`)"
          "-l=traefik.http.services.dashy.loadbalancer.server.port=80"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/dashy:/app/public"
        ];
        environment = {
          UID = "994";
          GID = "993";
        };
      };
    };
};
}
