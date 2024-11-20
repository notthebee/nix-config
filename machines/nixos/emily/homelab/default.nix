{ inputs, config, ... }:
{
  homelab = {
    enable = true;
    baseDomainName = "goose.party";
    timeZone = "Europe/Berlin";
    mounts = {
      config = "/persist/opt/services";
      slow = "/mnt/mergerfs_slow";
      fast = "/mnt/cache";
      merged = "/mnt/user";
    };
    services = {
      enable = true;
      homepage = {
        enable = true;
      };
      jellyfin = {
        enable = true;
        apiKeyFile = config.age.secrets.jellyfinApiKey.path;
      };
      paperless = {
        enable = true;
        apiKeyFile = config.age.secrets.paperlessApiKey.path;
        secretsFile = config.age.secrets.paperless.path;
        adminUser = "notthebee";
      };
      traefik = {
        enable = true;
        acme = {
          email = config.email.fromAddress;
          dnsChallenge.credentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
        };
      };
      arr = {
        enable = true;
        recyclarr = {
          configPath = inputs.recyclarr-configs;
        };
        sonarr = {
          apiKeyFile = config.age.secrets.sonarrApiKey.path;
        };
        radarr = {
          apiKeyFile = config.age.secrets.radarrApiKey.path;
        };
      };
      audiobookshelf = {
        enable = true;
      };
      calibre-web = {
        enable = true;
      };
      delugevpn = {
        enable = true;
        gluetun = {
          enable = true;
          wireguardCredentialsFile = config.age.secrets.wireguardCredentials.path;
        };
      };
    };
  };
}
