{ config, vars, ... }:
let
directories = [
"${vars.mainArray}/Media/Uploads"
"${vars.serviceConfigRoot}/pingvin"
"${vars.serviceConfigRoot}/pingvin/backend"
"${vars.serviceConfigRoot}/pingvin/frontend"
"${vars.serviceConfigRoot}/pingvin/frontend/icons"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      pingvin-share = {
        image = "stonith404/pingvin-share:latest";
        autoStart = true;
        dependsOn = [
          "pingvin-cloudflared"
        ];
        extraOptions = [
        "--network=container:pingvin-cloudflared"
        "-l=homepage.group=Services"
        "-l=homepage.name=pingvin-share"
        "-l=homepage.icon=pingvin-share.svg"
        "-l=homepage.href=https://share.${vars.domainName}"
        "-l=homepage.description=File sharing"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/pingvin/backend:/opt/app/backend/data"
          "${vars.mainArray}/Media/Uploads:/opt/app/frontend/public"
          "${vars.serviceConfigRoot}/pingvin/frontend:/opt/app/frontend/public/img"
          
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
        };
      };
      pingvin-cloudflared = {
        image = "cloudflare/cloudflared:latest";
        autoStart = true;
        cmd = [
        "tunnel"
        "--no-autoupdate" 
        "run"
        ];
        environment = {
          TZ = vars.timeZone;
          PUID = "994";
          GUID = "993";
        };
        environmentFiles = [
          config.age.secrets.pingvinCloudflared.path
        ];
      };
    };
};
}
