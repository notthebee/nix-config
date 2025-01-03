{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabledServices = lib.attrsets.mapAttrsToList (name: value: name) (
    lib.attrsets.filterAttrs (
      name: value: value ? configDir && value ? enable && value.enable
    ) config.homelab.services
  );

  networkInterface =
    if lib.attrsets.hasAttrByPath [ config.networking.hostName ] config.homelab.networks.external then
      config.homelab.networks.external.${config.networking.hostName}.interface
    else
      "";
  motd = pkgs.writeShellScriptBin "motd" ''
    #! /usr/bin/env bash
    source /etc/os-release
    RED="\e[31m"
    GREEN="\e[32m"
    YELLOW="\e[33m"
    BOLD="\e[1m"
    ENDCOLOR="\e[0m"
    LOAD1=`cat /proc/loadavg | awk {'print $1'}`
    LOAD5=`cat /proc/loadavg | awk {'print $2'}`
    LOAD15=`cat /proc/loadavg | awk {'print $3'}`

    MEMORY=`free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100 / $2 }'`

    # time of day
    HOUR=$(date +"%H")
    if [ $HOUR -lt 12  -a $HOUR -ge 0 ]
    then    TIME="morning"
    elif [ $HOUR -lt 17 -a $HOUR -ge 12 ]
    then    TIME="afternoon"
    else
        TIME="evening"
    fi


    uptime=`cat /proc/uptime | cut -f1 -d.`
    upDays=$((uptime/60/60/24))
    upHours=$((uptime/60/60%24))
    upMins=$((uptime/60%60))
    upSecs=$((uptime%60))

    printf "$BOLD Welcome to $(hostname)!$ENDCOLOR\n"
    printf "\n"
    ${lib.strings.concatMapStrings (x: "${x}\n") (
      lib.lists.forEach config.homelab.motd.networkInterfaces (
        x:
        lib.strings.concatMapStrings (x: "${x}\n") ([
          (
            if x == "" then
              ''
                NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
              ''
            else
              ''
                NETDEV=${x}
              ''
          )
          ''
            printf "$BOLD  * %-20s$ENDCOLOR %s\n" "IPv4 $NETDEV" "$(ip -4 addr show $NETDEV | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
          ''
        ])
      )
    )}
    printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Release" "$PRETTY_NAME"
    printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Kernel" "$(uname -rs)"
    printf "\n"
    printf "$BOLD  * %-20s$ENDCOLOR %s\n" "CPU usage" "$LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)"
    printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Memory" "$MEMORY"
    printf "$BOLD  * %-20s$ENDCOLOR %s\n" "System uptime" "$upDays days $upHours hours $upMins minutes $upSecs seconds"

    printf "\n"
    printf "$BOLD Service status$ENDCOLOR\n"

    function get_service_status() {
      statuses=$(systemctl list-units | grep $1 | grep service)
      while IFS= read -r line; do
        service_name=$(echo $line | awk '{print $1;}')
        if [[ $service_name =~ ".scope" || $service_name =~ ".mount" ]]; then
          continue
        fi
        if echo "$line" | grep -q 'failed'; then
          printf "$RED• $ENDCOLOR%-50s $RED[failed]$ENDCOLOR\n" "$service_name"
        elif echo "$line" | grep -q 'running'; then
          printf "$GREEN• $ENDCOLOR%-50s $GREEN[active]$ENDCOLOR\n" "$service_name"
        fi
      done <<< "$statuses"
    }
    ${lib.strings.concatStrings (lib.lists.forEach enabledServices (x: "get_service_status ${x}\n"))}
  '';
in
{
  options.homelab.motd = {
    enable = lib.mkEnableOption {
      description = "motd Greeting";
    };
    networkInterfaces = lib.mkOption {
      description = "Network interfaces to monitor";
      type = lib.types.listOf lib.types.str;
      default = [ networkInterface ];
    };
  };
  config = lib.mkIf config.homelab.motd.enable {
    environment.systemPackages = [ motd ];
  };
}
