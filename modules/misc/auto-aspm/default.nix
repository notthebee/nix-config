{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.auto-aspm;
  auto-aspm = pkgs.writeScriptBin "auto-aspm" (builtins.readFile "${inputs.auto-aspm}/autoaspm.py");
in
{
  options.services.auto-aspm = {
    enable = lib.mkEnableOption "Automatically activate ASPM on all supported devices";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      auto-aspm
    ];
    systemd.services.auto-aspm = {
      description = "Automatically activate ASPM on all supported devices";
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.python313
        pkgs.which
        pkgs.pciutils
        auto-aspm
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.python313} ${lib.getExe auto-aspm}";
      };
    };
  };
}
