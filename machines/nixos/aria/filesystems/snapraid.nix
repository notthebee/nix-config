{ inputs, config, pkgs, lib, ... }:
{
snapraid = {
  enable = true;
  parityFiles = [
    "/mnt/parity1/snapraid.parity"
  ];
  contentFiles = [
    "/mnt/data1/snapraid.content"
    "/mnt/data2/snapraid.content"
  ];
  dataDisks = {
    d1 = "/mnt/data1";
    d2 = "/mnt/data2";
  };
  exclude = [
    "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
      "/Media/"
  ];
};

systemd.services.snapraid-sync = {
  serviceConfig = {
    RestrictNamespaces = lib.mkForce false;
    RestrictAddressFamilies = lib.mkForce "";
  };
  postStop = ''
  if [[ $SERVICE_RESULT =~ "success" ]]; then
    message=""
  else
    message=$(journalctl --unit=snapraid-sync.service -n 20 --no-pager)
  fi
  /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "Snapraid Sync" -m "$message"
  '';
};

systemd.services.snapraid-scrub = {
  serviceConfig = {
    RestrictAddressFamilies = lib.mkForce "";
  };
  postStop = ''
  if [[ $SERVICE_RESULT =~ "success" ]]; then
    message=""
  else
    message=$(journalctl --unit=snapraid-scrub.service -n 20 --no-pager)
  fi
  /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "Snapraid Scrub" -m "$message"
  '';
};


}
