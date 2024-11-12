{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.lgtv;

  algaExec = "${lib.getExe pkgs.sudo} -u ${cfg.user} ${
    lib.getExe inputs.alga.packages.${pkgs.system}.default
  }";

  wolExec = "${lib.getExe pkgs.wol} --host ${cfg.ipAddress} ${cfg.macAddress}";

  lgtv-off = pkgs.writeShellScriptBin "lgtv-off" ''
    ${pkgs.systemd}/bin/systemctl restart NetworkManager.service
    ${pkgs.networkmanager}/bin/nm-online
    count=0
    while true; do
      if [ $count -gt 10 ]; then
        echo "Failed to power the TV input after $count tries"
        exit 1
      fi
      sleep 1
      result=$( ${algaExec} power off || echo "Error")
      if [[ $result = "Error" ]]; then
        count=$[count+1]
      else
        exit 0
      fi
    done
  '';

  lgtv-on = pkgs.writeShellScriptBin "lgtv-on" ''
    count=0
    while true; do
      if [ $count -gt 10 ]; then
        echo "Failed to switch the TV input after $count tries"
        exit 1
      fi
      ${wolExec}
      sleep 3
      result=$( ${algaExec} input list || true)
      if echo $result | ${lib.getExe pkgs.gnugrep} -q "${cfg.hdmiInput}"; then
        ${algaExec} input set ${cfg.hdmiInput}
        exit 0
      else
        count=$[count+1]
      fi
    done
  '';
in
{
  options.services.lgtv = {
    enable = lib.mkEnableOption "Enable the LG TV integration";
    ipAddress = lib.mkOption {
      description = "The IP address of the TV";
      type = lib.types.str;
    };
    macAddress = lib.mkOption {
      description = "The MAC address of the TV";
      type = lib.types.str;
    };
    hdmiInput = lib.mkOption {
      description = "The HDMI input of the machine on the LG TV";
      type = lib.types.str;
      default = "HDMI_4";
    };
    user = lib.mkOption {
      description = "User to run the LG TV commands as";
      type = lib.types.str;
    };
    group = lib.mkOption {
      description = "Group to run the LG TV commands as";
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wol
      pkgs.sudo
      inputs.alga.packages.${pkgs.system}.default
      lgtv-on
      lgtv-off
    ];
    powerManagement.enable = true;
    powerManagement.resumeCommands = lib.getExe lgtv-on;
    powerManagement.powerDownCommands = lib.getExe lgtv-off;

    systemd.services.lgtv-on = {
      description = "Turn the LG TV on";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.gnused
        pkgs.wol
        pkgs.sudo
        inputs.alga.packages.${pkgs.system}.default
        pkgs.systemd
        lgtv-on
      ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = lib.getExe lgtv-on;
    };
  };
}
