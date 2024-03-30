{ config, vars, ... }:
let
directories = [
"${vars.cacheArray}/Media/Kiwix"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      kiwix = {
        image = "ghcr.io/kiwix/kiwix-serve:latest";
        autoStart = true;
        extraOptions = [
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.kiwix.rule=Host(`kiwix.${vars.domainName}`)"
        "-l=traefik.http.services.kiwix.loadbalancer.server.port=8080"
        "-l=homepage.group=Services"
        "-l=homepage.name=Kiwix"
        "-l=homepage.icon=kiwix-light.png"
        "-l=homepage.href=https://kiwix.${vars.domainName}"
        "-l=homepage.description=Wiki mirror"
        ];
        cmd = [
          "*.zim"
          ];
        volumes = [
          "${vars.cacheArray}/Media/Kiwix:/data"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
        };
      };
    };
};
}
