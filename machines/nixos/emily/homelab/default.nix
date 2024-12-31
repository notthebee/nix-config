{ config, lib, ... }:
{
  homelab = {
    enable = true;
    baseDomain = "goose.party";
    cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
    timeZone = "Europe/Berlin";
    mounts = {
      config = "/persist/opt/services";
      slow = "/mnt/mergerfs_slow";
      fast = "/mnt/cache";
      merged = "/mnt/user";
    };
    services = {
      enable = true;
      backup = {
        enable = true;
        passwordFile = config.age.secrets.resticPassword.path;
        s3.enable = true;
        s3.url = "https://s3.eu-central-003.backblazeb2.com/notthebee-ojfca-backups";
        s3.environmentFile = config.age.secrets.resticBackblazeEnv.path;
        local.enable = true;
      };
      homepage = {
        enable = true;
        misc = [
          {
            PiKVM =
              let
                ip =
                  (lib.lists.findSingle (
                    x: x.hostname == "pikvm"
                  ) false false config.homelab.networks.local.lan.reservations).ip-address;
              in
              {
                href = "https://${ip}";
                siteMonitor = "https://${ip}";
                description = "Open-source KVM solution";
                icon = "pikvm.svg";
              };
          }
          {
            FritzBox = {
              href = "http://192.168.178.1";
              siteMonitor = "http://192.168.178.1";
              description = "Cable Modem WebUI";
              icon = "avmfritzbox.svg";
            };
          }
        ];
      };
      jellyfin.enable = true;
      paperless = {
        enable = true;
        passwordFile = config.age.secrets.paperlessPassword.path;
      };
      sabnzbd.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      bazarr.enable = true;
      prowlarr.enable = true;
      nextcloud = {
        enable = true;
        adminpassFile = config.age.secrets.nextcloudAdminPassword.path;
        cloudflared = {
          tunnelId = "cc246d42-a03d-41d4-97e2-48aa15d47297";
          credentialsFile = config.age.secrets.nextcloudCloudflared.path;
        };
      };
      vaultwarden = {
        enable = true;
        cloudflared = {
          tunnelId = "3bcbbc74-3667-4504-9258-f272ce006a18";
          credentialsFile = config.age.secrets.vaultwardenCloudflared.path;
        };
      };
      audiobookshelf.enable = true;
      delugevpn = {
        enable = true;
        wireguard = {
          configFile = config.age.secrets.wireguardCredentials.path;
          privateIP = "10.100.0.2";
          dnsIP = "10.100.0.1";
        };
      };
    };
  };
}
