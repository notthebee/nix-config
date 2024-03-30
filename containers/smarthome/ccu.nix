{ config, vars, pkgs, ... }:
let
directories = [
"${vars.serviceConfigRoot}/ccu"
];
  in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  services.udev.extraRules = ''
  ACTION=="add", ATTRS{idVendor}=="1b1f", ATTRS{idProduct}=="c020", RUN+="${pkgs.kmod}/bin/modprobe cp210x" RUN+="${pkgs.bash}/bin/bash -c 'echo 1b1f c020 > /sys/bus/usb-serial/drivers/cp210x/new_id'"
  '';
  virtualisation.oci-containers = {
    containers = {
      ccu = {
        image = "ghcr.io/jens-maus/raspberrymatic:latest";
        autoStart = true;
        hostname = "ccu";
        dependsOn = [ "homeassistant" ];
        extraOptions = [
        "--network=container:homeassistant"
        "-l=traefik.enable=true"
        "-l=traefik.http.routers.ccu.rule=Host(`ccu.${vars.domainName}`)"
        "-l=traefik.http.services.ccu.loadbalancer.server.port=80"
        "--privileged"
        "--device=/dev/ttyUSB0:/dev/ttyUSB0"
        ];
        volumes = [
          "${vars.serviceConfigRoot}/ccu:/usr/local:rw"
          "/run/current-system/kernel-modules:/lib/modules:ro"
        ];
        environment = {
          APP_NAME = "CCU";
          TZ = vars.timeZone;
          UID = "994";
          GID = "993";
        };
      };
    };
};
}
