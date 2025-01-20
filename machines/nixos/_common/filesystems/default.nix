{ config, lib, ... }:
let
  zfsFilesystems = lib.attrsets.filterAttrs (n: v: v.fsType == "zfs") config.fileSystems;
  zfsEnabled = zfsFilesystems != { };
in
{
  imports = [ ./snapraid.nix ];
  services = lib.mkIf zfsEnabled {
    zfs = {
      autoScrub.enable = true;
      zed.settings = {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
        ZED_EMAIL_ADDR = lib.lists.optionals (config ? email) [ config.email.toAddress ];
        ZED_EMAIL_PROG = "/run/current-system/sw/bin/tg-notify";
        ZED_EMAIL_OPTS = "-t '@SUBJECT@' -m";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      };
      zed.enableMail = false;
    };
  };
}
