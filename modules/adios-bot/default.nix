{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.services.adiosBot;
  inherit (builtins) head toString map tail concatStringsSep readFile fetchurl;
  inherit (lib) mkIf types mkDefault mkOption mkMerge strings;
  adiosBot = pkgs.writeScriptBin "adiosBot" (readFile "${inputs.adios-bot}/main.py");
in
{
  options.services.adiosBot = {
    enable = lib.mkEnableOption ("AdiosBot");

    botTokenFile = mkOption {
      description = "Path to the file with the Discord bot token";
      type = types.str;
      default = "/mnt/cache";
    };

    workingDir = mkOption {
      description = "Path to store the service files (e.g. user whitelist, message timestamps)";
      type = types.str;
      default = "/persist/opt/services/adiosbot";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      adiosBot
      (pkgs.python312Full.withPackages (ps: with ps; [
        discordpy
        pytz
      ]))
    ];

    systemd.services.adios-bot = {
      description = "AdiosBot";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        (pkgs.python312Full.withPackages (ps: with ps; [
          discordpy
          pytz
        ]))
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
