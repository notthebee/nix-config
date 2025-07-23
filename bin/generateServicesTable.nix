with builtins.getFlake (toString ../.);
let
  lib = import <nixpkgs/lib>;
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
        format = icon: if lib.strings.hasSuffix "svg" icon then "svg" else "png";
        iconlink =
          icon:
          "<img src='https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/${format icon}/${icon}' width=32 height=32>";
        serviceConfig = (hl hostname).services.${service}.homepage;
      in
      "|${iconlink serviceConfig.icon}|${serviceConfig.name}|${serviceConfig.description}|${serviceConfig.category}|"
    ) (enabledHomepageServices hostname);
  allHostsServiceData =
    let
      homelabHostnames = builtins.filter (x: x != null) (
        builtins.map (hostname: if (hl hostname).enable then hostname else null) (
          builtins.attrNames nixosConfigurations
        )
      );
    in
    builtins.map (
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
