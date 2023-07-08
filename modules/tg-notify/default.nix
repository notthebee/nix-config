{ config, pkgs, ... }: 
let
notify = pkgs.writeShellScriptBin "notify" ''
#!/bin/bash
set -x
api_key=$(cat ${config.age.secrets.telegramApiKey.path})
channel_id=$(cat ${config.age.secrets.telegramChannelId.path})
severity=$1
title=$2
message=$3
case $severity in
"success")
  emoji="✅"
  ;;
*)
  emoji="❌"
  ;;
esac

text="
$emoji <b>$title</b>
Exit status: <b>$severity</b>

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
