#!/bin/bash
createArray() {
  $@ | tail -c +2 | head -c -2 | sed 's/"enable"//'
}

getConfig() {
  echo $homepage_config | jq -r .$1
}

all_hostnames=$(createArray nix eval .#nixosConfigurations --apply 'builtins.attrNames')

for hostname in ${all_hostnames[@]}; do
  homelab_enabled=$(nix eval .#nixosConfigurations.$hostname.config.homelab.enable)
  if [ $homelab_enabled = false ]; then
    continue
  fi

  echo \#\# $hostname | sed 's/"//g'

  echo '|Icon|Service|Description|Category|'
  echo '|---|---|---|---|'
  all_services=$(createArray nix eval .#nixosConfigurations.$hostname.config.homelab.services --apply 'builtins.attrNames')
  for i in ${all_services[@]}; do
    service_enabled=$(nix eval .#nixosConfigurations.$hostname.config.homelab.services.$i.enable)
    if [ $service_enabled = true ]; then
      homepage_enabled=$(nix eval .#nixosConfigurations.$hostname.config.homelab.services.$i --apply 'builtins.hasAttr("homepage")')
      if [ $homepage_enabled = true ]; then
        homepage_config=$(nix eval .#nixosConfigurations.$hostname.config.homelab.services.$i.homepage --json)
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
