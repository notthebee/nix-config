{ config, ... }:
let
  hl = config.homelab;
in
{
  homelab = {
    enable = true;
    cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
    baseDomain = "aria.goose.party";
    timeZone = "Europe/Berlin";
    mounts = {
      slow = "/mnt/mergerfs_slow";
      fast = "/mnt/user";
      config = "/persist/opt/services";
    };
    services = {
      backup = {
        enable = true;
        passwordFile = config.age.secrets.resticPassword.path;
        s3.enable = true;
        s3.url = "https://s3.eu-central-003.backblazeb2.com/notthebee-ojfca-backups";
        s3.environmentFile = config.age.secrets.resticBackblazeEnv.path;
        local.enable = true;
        local.targetDir = "${hl.mounts.fast}/Backups/Restic";
      };
      enable = true;
      immich.enable = true;
    };
    samba = {
      enable = true;
      passwordFile = config.age.secrets.sambaPassword.path;
      shares = {
        Backups = {
          path = "${hl.mounts.slow}/Backups";
        };
        YouTube = {
          path = "${hl.mounts.slow}/YouTube";
        };
        Media = {
          path = "${hl.mounts.slow}/Media";
        };
        Photos = {
          path = "${hl.mounts.fast}/Photos";
        };
      };
    };
  };

}
