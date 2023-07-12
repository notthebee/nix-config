{ config, pkgs, ... }: 
let
notify = pkgs.writeShellScriptBin "notify" 
''
#!/bin/bash
api_key=$(cat ${config.age.secrets.telegramApiKey.path})
channel_id=$(cat ${config.age.secrets.telegramChannelId.path})


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
    -s)
      severity="$2"
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

set -- "''${POSITIONAL_ARGS[@]}"

declare -a error_messages=(
"Permanent errors have been detected"
"UNAVAIL"
"devices are faulted"
)

if [ -z "''${message}" ] || [ "''${message}" == " " ]; then
  message=$(</dev/stdin)
fi

if [ -z "''${severity}" ] || [ "''${severity}" == " " ]; then
  emoji="✅"
  for i in "''${error_messages[@]}"; do
    if [[ "$message" == *"$i"* ]]; then
      emoji="❌"
    fi
  done
else
  case ''${severity} in
  "success")
    emoji="✅"
    ;;
  *)
    emoji="❌"
    ;;
  esac
  status="Status: ''$severity"
fi

text="
$emoji <b>$title</b>
$status
$(date)

<code>$message</code>
"
/run/current-system/sw/bin/curl -s --data "chat_id=$channel_id" \
        --data-urlencode "text=$text" \
        --data-urlencode "parse_mode=HTML" \
        https://api.telegram.org/$api_key/sendMessage > /dev/null
'';
in 
{
  environment.systemPackages = [ notify ];
}
