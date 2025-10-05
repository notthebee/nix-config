{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.ryzen-undervolting;
  ryzen-undervolting = pkgs.callPackage ./package.nix { };
in
{
  options.services.ryzen-undervolting = {
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
        message = "service.ryzen-undervolting.offset has to be less than 0";
      }
      {
        assertion = cfg.coreCount >= 1 && cfg.coreCount <= 16;
        message = "service.ryzen-undervolting.coreCount has to be a number between 1 and 16";
      }
    ];
    environment.systemPackages = [
      ryzen-undervolting
    ];
    hardware.cpu.amd.ryzen-smu.enable = true;
    systemd.services.ryzen-undervolting = {
      description = "Ryzen 5800x3D undervolting service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.python3} ${lib.getExe ryzen-undervolting} -c ${builtins.toString cfg.coreCount} -o ${builtins.toString cfg.offset}";
      };
    };
  };
}
