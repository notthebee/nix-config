{ vars, ... }:
let
directories = [
  "${vars.serviceConfigRoot}/syncthing"
];
in
{
  systemd.tmpfiles.rules = map (x: "d ${x} 0775 share share - -") directories;
  networking.firewall = {
    allowedTCPPorts = [ 8384 22000 ];
    allowedUDPPorts = [ 22000 21027 ];
  };
  services = {
    syncthing = {
      enable = true;
      user = "share";
      guiAddress = "0.0.0.0:8384";
      overrideFolders = false;
      dataDir = "${vars.slowArray}/Syncthing";
      configDir = "${vars.serviceConfigRoot}/syncthing";
      settings = {
        devices = {
          "s10-m" = { id = "HA7S6JT-JU53UKD-CPXHPTN-75U2675-OQXMDKM-I6556KS-FEHH7HI-DWVOFAK"; };
        };
        folders = {
          "Photos" = {
            path = "${vars.mainArray}/Photos/S10m";
            id = "Photos";
            label = "Photos";
            devices = [ "s10-m" ];
          };
        };
      };
    };
  };
}
