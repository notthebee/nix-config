{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.withings2intervals;
  withings2intervals = pkgs.callPackage ./package.nix { };
in
{
  options.services.withings2intervals = {
    enable = lib.mkEnableOption "Sync wellness data from Withings to Intervals.icu";
    authCodeFile = lib.mkOption {
      description = "Path to withings2intervals auth code";
      type = lib.types.str;
    };
    configFile = lib.mkOption {
      description = "Path to withings2intervals config file";
      type = lib.types.str;
      example = lib.literalExpression ''
        pkgs.writeText "config.ini" '''
          [Withings]
          client_id = YOUR_CLIENT_ID
          client_secret = YOUR_CLIENT_SECRET
          redirect_uri = http://localhost:80

          [Intervals]
          icu_api_key = YOUR_ICU_API_KEY
          icu_athlete_id = YOUR_ATHLETE_ID

          [Fields]
          weight_field = weight
          bodyfat_field = bodyFat
          diastolic_field = diastolic
          systolic_field = systolic
          muscle_field = MuscleMass
          temp_field = BodyTemperature

          [General]
          withings_config = ./withings.json
        '''
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      timers.withings2intervals = {
        wantedBy = [ "multi-user.target" ];
        timerConfig = {
          OnBootSec = "1min";
          OnUnitActiveSec = "10min";
          Unit = "withings2intervals.service";
        };
      };
      services.withings2intervals = {
        description = "Sync wellness data from Withings to Intervals.icu";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          LoadCredential = "W2I_AUTHCODE_FILE:${cfg.authCodeFile}";
          Type = "oneshot";
          StateDirectory = "withings2intervals";
          RuntimeDirectory = "withings2intervals";
          WorkingDirectory = "/var/lib/withings2intervals";
        };
        script = ''
          export W2I_AUTHCODE=$(systemd-creds cat W2I_AUTHCODE_FILE)
          ${lib.getExe withings2intervals} --config ${cfg.configFile} --auth-code $W2I_AUTHCODE
        '';
      };
    };
  };
}
