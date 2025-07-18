{ config, ... }:
let
  hl = config.homelab;
  directories = [
    "${hl.mounts.config}/syncthing"
  ];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  networking.firewall = {
    allowedTCPPorts = [
      8384
      22000
    ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };
  services = {
    syncthing = {
      enable = true;
      user = "share";
      guiAddress = "0.0.0.0:8384";
      overrideFolders = false;
      overrideDevices = false;
      dataDir = "${hl.mounts.fast}/Syncthing";
      configDir = "${hl.mounts.config}/syncthing";
    };
  };
}
