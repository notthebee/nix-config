{
  config,
  pkgs,
  vars,
  ...
}:
let
  directories = [ "${vars.serviceConfigRoot}/vaultwarden" ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  virtualisation.oci-containers = {
    containers = {
      vaultwarden = {
        image = "vaultwarden/server:latest";
        autoStart = true;
        dependsOn = [ "vaultwarden-cloudflared" ];
        extraOptions = [
          "--pull=newer"
          "--network=container:vaultwarden-cloudflared"
          "-l=homepage.group=Services"
          "-l=homepage.name=Vaultwarden"
          "-l=homepage.icon=bitwarden.svg"
          "-l=homepage.href=https://pass.${vars.domainName}"
          "-l=homepage.description=Password manager"
        ];
        volumes = [ "${vars.serviceConfigRoot}/vaultwarden:/data" ];
        environment = {
          DOMAIN = "https://pass.${vars.domainName}";
          WEBSOCKET_ENABLED = "true";
          SIGNUPS_ALLOWED = "false";
          LOG_FILE = "data/vaultwarden.log";
          LOG_LEVEL = "warn";
          IP_HEADER = "CF-Connecting-IP";
        };
      };
      vaultwarden-cloudflared = {
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
        environmentFiles = [ config.age.secrets.vaultwardenCloudflared.path ];
        extraOptions = [ "--pull=newer" ];
      };
    };
  };
}
