{ config, ... }:
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
      homepage.enable = true;
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
