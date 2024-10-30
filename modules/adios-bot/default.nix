{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.services.adiosBot;
  adiosBot = pkgs.writeScriptBin "adiosBot" (builtins.readFile "${inputs.adios-bot}/main.py");
in
{
  options.services.adiosBot = {
    enable = lib.mkEnableOption ("AdiosBot");

    botTokenFile = lib.mkOption {
      description = "Path to the file with the Discord bot token";
      type = lib.types.str;
      default = "/mnt/cache";
    };

    workingDir = lib.mkOption {
      description = "Path to store the service files (e.g. user whitelist, message timestamps)";
      type = lib.types.str;
      default = "/persist/opt/services/adiosbot";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      adiosBot
      (pkgs.python312Full.withPackages (
        ps: with ps; [
          discordpy
          pytz
        ]
      ))
    ];

    systemd.services.adios-bot = {
      description = "AdiosBot";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        (pkgs.python312Full.withPackages (
          ps: with ps; [
            discordpy
            pytz
          ]
        ))
        pkgs.systemd
        pkgs.coreutils
        pkgs.gawk
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "/run/current-system/sw/bin/adiosBot";
        EnvironmentFile = cfg.botTokenFile;
        Environment = "WORKING_DIR=${cfg.workingDir}";
      };
    };
  };
}
