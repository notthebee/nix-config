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
systemd.network.enable = true;

systemd.services.snapraid-sync = {
  serviceConfig = {
    RestrictNamespaces = lib.mkForce false;
  };
};

systemd.services.snapraid-scrub = {
  unitConfig = {
    After = lib.mkForce "snapraid-sync.service nss-lookup.target";
  };
  serviceConfig = {
    RestrictAddressFamilies = lib.mkForce "";
  };
  postStop = ''
  /run/current-system/sw/bin/bash -c '/run/current-system/sw/bin/notify "$SERVICE_RESULT" "Snapraid Scrub" "$(journalctl --unit=snapraid-sync.service -n 20 --no-pager)"'
  '';
};

}
