{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.prometheus.exporters.shellyplug;
in
{
  options.services.prometheus.exporters.shellyplug = {
    enable = lib.mkEnableOption {
      description = "Enable Shelly Plug Prometheus exporter";
    };
    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "A list of Shelly IP addresses";
      default = [ ];
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7128;
    };
  };
  config = lib.mkIf cfg.enable {

    systemd.services."prometheus-shellyplug-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        SHELLY_DEVICES_HOSTS = lib.strings.concatStringsSep "," cfg.targets;
        SERVER_PORT = toString cfg.port;
      };
      serviceConfig = {
        Restart = lib.mkDefault "always";
        PrivateTmp = lib.mkDefault true;
        DynamicUser = true;
        # Hardening
        CapabilityBoundingSet = lib.mkDefault [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = lib.mkDefault true;
        ProtectClock = lib.mkDefault true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = lib.mkDefault "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
        ExecStart = lib.getExe (pkgs.callPackage ./package.nix { });
      };
    };

  };
}
