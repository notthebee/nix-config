{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.ryzen-undervolt;
  ryzen-undervolt = pkgs.writeScriptBin "ryzen-undervolt" (
    builtins.readFile "${inputs.ryzen-undervolt}/ruv.py"
  );
in
{
  options.services.ryzen-undervolt = {
    enable = lib.mkEnableOption "Ryzen 5800x3D undervolting service";
    offset = lib.mkOption {
      description = "The voltage offet in mV";
      type = lib.types.int;
      default = -20;
    };
    coreCount = lib.mkOption {
      description = "The cores to which the offset should be applied (0..corecount)";
      type = lib.types.int;
      default = 8;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.offset <= 0;
        message = "service.ryzen-undervolt.offset has to be less than 0";
      }
      {
        assertion = cfg.coreCount >= 1 && cfg.coreCount <= 16;
        message = "service.ryzen-undervolt.coreCount has to be a number between 1 and 16";
      }
    ];
    environment.systemPackages = [
      ryzen-undervolt
      pkgs.python312Full
    ];
    systemd.services.ryzen-undervolt = {
      description = "Ryzen 5800x3D undervolting service";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.python312Full ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.python312Full} ${lib.getExe ryzen-undervolt} -c ${builtins.toString cfg.coreCount} -o ${builtins.toString cfg.offset}";
      };
    };
  };
}
