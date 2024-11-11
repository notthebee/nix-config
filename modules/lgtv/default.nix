{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.lgtv;
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
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wol
      inputs.alga.packages.${pkgs.system}.default
    ];
    systemd.services.lgtv-on = {
      description = "Turn on the LG TV on boot";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.wol ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.wol} --host ${cfg.ipAddress} ${cfg.macAddress}";
      };
    };
    systemd.services.lgtv-off = {
      description = "Turn off the LG TV on suspend/poweroff";
      wantedBy = [
        "sleep.target"
        "poweroff.target"
      ];
      path = [ inputs.alga.packages.${pkgs.system}.default ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe inputs.alga.packages.${pkgs.system}.default} power off";
      };
    };

  };
}
