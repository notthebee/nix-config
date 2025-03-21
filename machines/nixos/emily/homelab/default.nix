{ config, lib, ... }:
let
  hl = config.homelab;
in
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
    samba = {
      enable = true;
      passwordFile = config.age.secrets.sambaPassword.path;
      shares = {
        Backups = {
          path = "${hl.mounts.merged}/Backups";
        };
        Documents = {
          path = "${hl.mounts.fast}/Documents";
        };
        Media = {
          path = "${hl.mounts.merged}/Media";
        };
        Music = {
          path = "${hl.mounts.fast}/Media/Music";
        };
        Misc = {
          path = "${hl.mounts.merged}/Misc";
        };
        TimeMachine = {
          path = "${hl.mounts.fast}/TimeMachine";
          "fruit:time machine" = "yes";
        };
        YoutubeArchive = {
          path = "${hl.mounts.merged}/YoutubeArchive";
        };
        YoutubeCurrent = {
          path = "${hl.mounts.fast}/YoutubeCurrent";
        };
      };
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
      radicale = {
        enable = true;
        passwordFile = config.age.secrets.radicaleHtpasswd.path;
      };
      immich = {
        enable = true;
        mediaDir = "${hl.mounts.fast}/Media/Photos";
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
                icon = "pikvm.png";
              };
          }
          {
            FritzBox = {
              href = "http://192.168.178.1";
              siteMonitor = "http://192.168.178.1";
              description = "Cable Modem WebUI";
              icon = "avm-fritzbox.png";
            };
          }
          {
            "Immich (Parents)" = {
              href = "https://photos.aria.goose.party";
              description = "Self-hosted photo and video management solution";
              icon = "immich.svg";
              siteMonitor = "";
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
      microbin = {
        enable = true;
        cloudflared = {
          tunnelId = "216d72b6-6b2b-412f-90bc-1a44c1264871";
          credentialsFile = config.age.secrets.microbinCloudflared.path;
        };
      };
      miniflux = {
        enable = true;
        cloudflared = {
          tunnelId = "9b2cac61-a439-4b1f-a979-f8519ea00e58";
          credentialsFile = config.age.secrets.minifluxCloudflared.path;
        };
        adminCredentialsFile = config.age.secrets.minifluxAdminPassword.path;
      };
      audiobookshelf.enable = true;
      deluge.enable = true;
      wireguard-netns = {
        enable = true;
        configFile = config.age.secrets.wireguardCredentials.path;
        privateIP = "10.100.0.2";
        dnsIP = "10.100.0.1";
      };
    };
  };
}
