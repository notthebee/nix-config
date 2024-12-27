{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.raspberrymatic;
  homelab = config.homelab;
in
{
  options.homelab.services.raspberrymatic = {
    enable = lib.mkEnableOption {
      description = "Enable RaspberryMatic";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d /var/lib/raspberrymatic 0775 ${homelab.user} ${homelab.group} - -" ];
    services.udev.extraRules = ''
      ACTION=="add", ATTRS{idVendor}=="1b1f", ATTRS{idProduct}=="c020", RUN+="${pkgs.kmod}/bin/modprobe cp210x" RUN+="${pkgs.bash}/bin/bash -c 'echo 1b1f c020 > /sys/bus/usb-serial/drivers/cp210x/new_id'"
    '';
    virtualisation = {
      podman.enable = true;
      oci-containers = {
        containers = {
          ccu = {
            image = "ghcr.io/jens-maus/raspberrymatic:latest";
            autoStart = true;
            hostname = "ccu";
            extraOptions = [
              "--pull=newer"
              "--network=host"
              "--privileged"
              "--device=/dev/ttyUSB0:/dev/ttyUSB0"
            ];
            volumes = [
              "/var/lib/raspberrymatic:/usr/local:rw"
              "/run/current-system/kernel-modules:/lib/modules:ro"
            ];
            environment = {
              APP_NAME = "CCU";
              TZ = homelab.timeZone;
              UID = homelab.user;
              GID = homelab.group;
            };
          };
        };
      };
    };
  };
}
