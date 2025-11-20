{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  hl = config.homelab;
in
{
  homelab = {
    enable = true;
    baseDomain = "goose.party";
    cloudflare.dnsCredentialsFile = "/persist/secrets/cloudflareDnsApiCredentials";
    timeZone = "Europe/Berlin";
    mounts = {
      config = "/persist/opt/services";
      slow = "/mnt/data";
      fast = "/mnt/data";
      merged = "/mnt/data";
    };
    samba = {
      enable = true;
      passwordFile = "/persist/secrets/sambaPassword";
      shares = {
        Backups = {
          path = "${hl.mounts.merged}/Backups";
        };
        Documents = {
          path = "${hl.mounts.merged}/Documents";
        };
        Media = {
          path = "${hl.mounts.merged}/Media";
        };
        Music = {
          path = "${hl.mounts.merged}/Media/Music";
        };
        Misc = {
          path = "${hl.mounts.merged}/Misc";
        };
        TimeMachine = {
          path = "${hl.mounts.merged}/TimeMachine";
          "fruit:time machine" = "yes";
        };
      };
    };
    services = {
      enable = true;
      slskd = {
        enable = true;
        environmentFile = "/persist/secrets/slskdEnvironmentFile";
      };
      backup = {
        enable = true;
        passwordFile = "/persist/secrets/resticPassword";
        s3.enable = false;
        local.enable = true;
      };
      keycloak = {
        enable = true;
        dbPasswordFile = "/persist/secrets/keycloakDbPasswordFile";
        cloudflared = {
          tunnelId = "06b27fd2-4cb9-42e5-9d79-f4c4c44ca0c6";
          credentialsFile = "/persist/secrets/keycloakCloudflared";
        };
      };
      radicale = {
        enable = true;
        passwordFile = "/persist/secrets/radicaleHtpasswd";
      };
      immich = {
        enable = true;
        mediaDir = "${hl.mounts.merged}/Media/Photos";
      };
      invoiceplane = {
        enable = true;
      };
      homepage = {
        enable = true;
        misc = [];
      };
      jellyfin.enable = true;
      paperless = {
        enable = true;
        passwordFile = "/persist/secrets/paperlessPassword";
      };
      sabnzbd.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      bazarr.enable = true;
      prowlarr.enable = true;
      jellyseerr = {
        enable = true;
        package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.jellyseerr;
      };
      nextcloud = {
        enable = true;
        admin = {
          username = "notthebee";
          passwordFile = "/persist/secrets/nextcloudAdminPassword";
        };
        cloudflared = {
          tunnelId = "cc246d42-a03d-41d4-97e2-48aa15d47297";
          credentialsFile = "/persist/secrets/nextcloudCloudflared";
        };
      };
      vaultwarden = {
        enable = true;
        cloudflared = {
          tunnelId = "3bcbbc74-3667-4504-9258-f272ce006a18";
          credentialsFile = "/persist/secrets/vaultwardenCloudflared";
        };
      };
      microbin = {
        enable = true;
        cloudflared = {
          tunnelId = "216d72b6-6b2b-412f-90bc-1a44c1264871";
          credentialsFile = "/persist/secrets/microbinCloudflared";
        };
      };
      miniflux = {
        enable = true;
        cloudflared = {
          tunnelId = "9b2cac61-a439-4b1f-a979-f8519ea00e58";
          credentialsFile = "/persist/secrets/minifluxCloudflared";
        };
        adminCredentialsFile = "/persist/secrets/minifluxAdminPassword";
      };
      navidrome = {
        enable = true;
        environmentFile = "/persist/secrets/navidromeEnv";
        cloudflared = {
          tunnelId = "dc669277-8528-4a25-bacb-b844a262de17";
          credentialsFile = "/persist/secrets/navidromeCloudflared";
        };
      };
      audiobookshelf.enable = true;
      deluge.enable = true;
    };
  };
}
