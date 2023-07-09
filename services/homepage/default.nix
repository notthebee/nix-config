{ config, vars, ... }:
let
directories = [
"${vars.serviceConfigRoot}/homepage"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      homepage = {
        image = "ghcr.io/benphelps/homepage:latest";
        autoStart = true;
        extraOptions = [
          "-l=traefik.enable=true"
          "-l=traefik.http.routers.homepage.rule=Host(`${vars.domainName}`)"
          "-l=traefik.http.services.homepage.loadbalancer.server.port=3000"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/homepage:/app/config"
          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
          "${vars.slowArray}:${vars.slowArray}:ro"
          "${vars.cacheArray}:${vars.cacheArray}:ro"
          "${vars.mainArray}:${vars.mainArray}:ro"
        ];
};
};
};
}
