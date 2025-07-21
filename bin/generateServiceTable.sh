#!/bin/bash
createArray() {
  $@ | tail -c +2 | head -c -2 | sed 's/"enable"//'
}

getConfig() {
  echo $homepage_config | jq -r .$1
}

all_hostnames=$(createArray nix --quiet eval .#nixosConfigurations --apply 'builtins.attrNames' 2>/dev/null)

for hostname in ${all_hostnames[@]}; do
  homelab_enabled=$(nix --quiet eval .#nixosConfigurations.$hostname.config.homelab.enable 2>/dev/null)
  if [ $homelab_enabled = false ]; then
    continue
  fi

  echo \#\# $hostname | sed 's/"//g'

  echo '|Icon|Service|Description|Category|'
  echo '|---|---|---|---|'
  all_services=$(createArray nix --quiet eval .#nixosConfigurations.$hostname.config.homelab.services --apply 'builtins.attrNames' 2>/dev/null)
  for i in ${all_services[@]}; do
    service_enabled=$(nix --quiet eval .#nixosConfigurations.$hostname.config.homelab.services.$i.enable 2>/dev/null)
    if [ $service_enabled = true ]; then
      homepage_enabled=$(nix --quiet eval .#nixosConfigurations.$hostname.config.homelab.services.$i --apply 'builtins.hasAttr("homepage")' 2>/dev/null)
      if [ $homepage_enabled = true ]; then
        homepage_config=$(nix --quiet eval .#nixosConfigurations.$hostname.config.homelab.services.$i.homepage --json 2>/dev/null)
        name=$(getConfig name)
        category=$(getConfig category)
        description=$(getConfig description)
        icon="$(getConfig icon)"
        icontype=$(echo $icon | grep -o "svg\|png")
        iconlink="https://raw.githubusercontent.com/homarr-labs/dashboard-icons/refs/heads/main/$icontype/$icon"
        iconhtml="<img src='$iconlink' alt='$name' width=32 height=32>"
        line=$(printf "|$iconhtml|$name|$description|$category|")
        echo $line
      fi
    fi
  done
  printf "\n"
done
