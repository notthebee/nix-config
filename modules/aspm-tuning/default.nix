{ config, pkgs, ... }: 
let
aspm_tuning = pkgs.writeShellScriptBin "aspm_tuning" (builtins.readFile ./aspm_tuning.sh);
in {
  environment.systemPackages = [ 
  pkgs.pciutils
  pkgs.bc
  aspm_tuning 
  ];


systemd.services.aspm_tuning = {
  description = "Enable ASPM correctly for all supported devices";
  wantedBy = [ "multi-user.target" ];
  path = [
    pkgs.gnused
    pkgs.pciutils
    pkgs.bc
  ];
  serviceConfig = {
    ExecStart = "/run/current-system/sw/bin/bash -c '/run/current-system/sw/bin/aspm_tuning'";
    Type = "oneshot";
  };
};
}
