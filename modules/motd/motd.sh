#! /usr/bin/env bash
service_status=$(systemctl list-units | grep podman-)
RED="\e[31m"
GREEN="\e[32m"
BOLD="\e[1m"
ENDCOLOR="\e[0m"

if_gig="enp3s0"
if_10g="enp1s0f0"

ip_main="$(ip -4 addr show $if_gig | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
ip_10g="$(ip -4 addr show $if_10g | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"

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

printf "${BOLD}Welcome to $(hostname)!${ENDCOLOR}\n"
printf "\n"
printf "${BOLD}  * %-20s${ENDCOLOR} %s\n" "IPv4 $if_gig" $ip_main
printf "${BOLD}  * %-20s${ENDCOLOR} %s\n" "IPv4 $if_10g" $ip_10g
printf "${BOLD}  * %-20s${ENDCOLOR} %s\n" "Release" "$(nixos-version)"
printf "${BOLD}  * %-20s${ENDCOLOR} %s\n" "Kernel" "$(uname -rs)"
printf "\n"
printf "${BOLD}  * %-20s${ENDCOLOR} %s\n" "CPU usage" "$LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)"
printf "${BOLD}  * %-20s${ENDCOLOR} %s\n" "Memory" "$MEMORY"
printf "${BOLD}  * %-20s${ENDCOLOR} %s\n" "System uptime" "$upDays days $upHours hours $upMins minutes $upSecs seconds"

printf "\n"
printf "${BOLD}Service status${ENDCOLOR}\n"

while IFS= read -r line; do
  if [[ $line =~ ".scope" ]]; then
    continue
  fi
  if echo "$line" | grep -q 'failed'; then
    service_name=$(echo $line | awk '{print $2;}' | sed 's/podman-//g')
    printf "${RED}• ${ENDCOLOR}%-50s ${RED}[failed]${ENDCOLOR}\n" "$service_name"
  elif echo "$line" | grep -q 'running'; then
    service_name=$(echo $line | awk '{print $1;}' | sed 's/podman-//g')
    printf "${GREEN}• ${ENDCOLOR}%-50s ${GREEN}[active]${ENDCOLOR}\n" "$service_name"
  else
    echo "service status unknown"
  fi
done <<< "$service_status"
