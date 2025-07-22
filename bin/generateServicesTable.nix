with builtins.getFlake (toString ../.);
let
  lib = import <nixpkgs/lib>;
  homelabHostnames =
    let
      hostnames = builtins.attrNames nixosConfigurations;
    in
    builtins.filter (x: x != null) (
      builtins.map (hostname: if (hl hostname).enable then hostname else null) hostnames
    );
  hl = hostname: nixosConfigurations.${hostname}.config.homelab;
  enabledHomepageServices =
    let
      services = hostname: builtins.filter (x: x != "enable") (builtins.attrNames (hl hostname).services);
    in
    hostname:
    builtins.filter (x: x != null) (
      builtins.map (
        x:
        if ((hl hostname).services.${x}.enable && (hl hostname).services.${x} ? homepage) then x else null
      ) (services hostname)
    );
  homepageServicesData =
    hostname:
    builtins.map (
      service:
      let
        iconlink =
          icon:
          let
            format = if lib.strings.hasSuffix "svg" icon then "svg" else "png";
          in
          "<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/${format}/${icon}' width=32 height=32>";
        serviceConfig = (hl hostname).services.${service}.homepage;
      in
      "|${iconlink serviceConfig.icon}|${serviceConfig.name}|${serviceConfig.description}|${serviceConfig.category}|"
    ) (enabledHomepageServices hostname);
  allHostsServiceData = builtins.map (
    hostname:
    lib.strings.concatLines [
      "### ${hostname}"
      "|Icon|Name|Description|Category|"
      "|---|---|---|---|"
      (lib.strings.concatLines (homepageServicesData hostname))
    ]
  ) homelabHostnames;
in
lib.strings.concatLines allHostsServiceData
