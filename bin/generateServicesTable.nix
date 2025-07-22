with builtins.getFlake (toString ../.);
let
  lib = import <nixpkgs/lib>;
  hostnames = builtins.attrNames nixosConfigurations;
  homelabHostnames = builtins.filter (x: x != null) (
    builtins.map (
      hostname: if nixosConfigurations.${hostname}.config.homelab.enable then hostname else null
    ) hostnames
  );
  services =
    hostname:
    builtins.filter (x: x != "enable") (
      builtins.attrNames nixosConfigurations.${hostname}.config.homelab.services
    );
  enabledHomepageServices =
    hostname:
    builtins.filter (x: x != null) (
      builtins.map (
        x:
        if
          (
            nixosConfigurations.${hostname}.config.homelab.services.${x}.enable
            && nixosConfigurations.${hostname}.config.homelab.services.${x} ? homepage
          )
        then
          x
        else
          null
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
        serviceConfig = nixosConfigurations.${hostname}.config.homelab.services.${service}.homepage;
      in
      "|${iconlink serviceConfig.icon}|${serviceConfig.name}|${serviceConfig.description}|${serviceConfig.category}|"
    ) (enabledHomepageServices hostname);
  allHostsServiceData = builtins.map (
    hostname:
    lib.strings.concatLines [
      "### ${hostname}"
      "|Icon|Name|Category|Description|"
      "|---|---|---|---|"
      (lib.strings.concatLines (homepageServicesData hostname))
    ]
  ) homelabHostnames;
in
lib.strings.concatLines allHostsServiceData
