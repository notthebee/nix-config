{ config, lib, ... }:
{
  services.snapraid.exclude = [
    "*.unrecoverable"
    "/tmp/"
    "/lost+found/"
    "/Media/"
  ];

  systemd.services = lib.attrsets.optionalAttrs (config.services.snapraid.enable) {
    snapraid-sync = {
      onFailure = lib.lists.optionals (config ? tg-notify && config.tg-notify.enable) [
        "tg-notify@%i.service"
      ];
      serviceConfig = {
        RestrictNamespaces = lib.mkForce false;
        RestrictAddressFamilies = lib.mkForce "";
      };
    };
    snapraid-scrub = {
      onFailure = lib.lists.optionals (config ? tg-notify && config.tg-notify.enable) [
        "tg-notify@%i.service"
      ];
      serviceConfig = {
        RestrictNamespaces = lib.mkForce false;
        RestrictAddressFamilies = lib.mkForce "";
      };
    };
  };
}
