{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.tg-notify;
  tg-notify = pkgs.writeShellScriptBin "tg-notify" ''
    #!/bin/bash

    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
      case $1 in
        -t)
          title="$2"
          shift # past argument
          shift # past value
          ;;
        -m)
          message="$2"
          shift # past argument
          shift # past value
          ;;
        -*|--*)
          echo "Unknown option $1"
          exit 1
          ;;
        *)
          POSITIONAL_ARGS+=("$1") # save positional arg
          shift # past argument
          ;;
      esac
    done

    declare -a error_messages=(
    "Permanent errors have been detected"
    "UNAVAIL"
    "devices are faulted"
    "DEGRADED"
    "unrecoverable error"
    )

    set -- "''${POSITIONAL_ARGS[@]}"

    hostname=$(${pkgs.systemd}/bin/hostnamectl hostname)
    if [[ $title =~ "service" ]]; then
      final_title="❌ Service $title failed on $hostname"
      final_message=$(${pkgs.systemd}/bin/journalctl --unit=$title -n 20 --no-pager)
    else
      emoji="✅"
      for i in "''${error_messages[@]}"; do
        if [[ "$message" == *"$i"* ]]; then
          emoji="❌"
        fi
      done
      final_title="$emoji $title on $hostname"
      final_message=$message
    fi

    text="
    <b>$final_title</b>

    <code>$final_message</code>
    "
    /run/current-system/sw/bin/curl --data "chat_id=$CHANNEL_ID" \
            --data-urlencode "text=$text" \
            --data-urlencode "parse_mode=HTML" \
            https://api.telegram.org/$API_KEY/sendMessage

  '';
in
{
  options.tg-notify = {
    enable = lib.mkEnableOption {
      description = "Send a Telegram notification on service failure";
    };
    credentialsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file with the Telegram API key and channel ID";
      example = lib.literalExpression ''
        pkgs.writeText "telegram-credentials" '''
          API_KEY=secret
          CHANNEL_ID=secret
        '''
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."tg-notify@" = {
      description = "Send a Telegram notification on service failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe tg-notify} -t %i.service";
        EnvironmentFile = cfg.credentialsFile;
      };
    };
    environment.systemPackages = [ tg-notify ];
  };
}
