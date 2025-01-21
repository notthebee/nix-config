{
  lib,
  config,
  pkgs,
  vars,
  ...
}:
let
  externalInterface = "wan0";
  networks = config.homelab.networks.local;
  internalInterfaces = lib.mapAttrsToList (_: val: val.interface) networks;
  internalIPs = lib.mapAttrsToList (
    _: val: lib.strings.removeSuffix ".1" val.cidr + ".0/24"
  ) networks;
in
{
  _module.args = {
    externalInterface = externalInterface;
    internalInterfaces = internalInterfaces;
    internalIPs = internalIPs;
  };
  imports = [
    ./dns.nix
    ./firewall.nix
    ./wireguard.nix
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:57", ATTR{type}=="1", NAME="wan0"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:56", ATTR{type}=="1", NAME="lan0"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:55", ATTR{type}=="1", NAME="lan1"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:54", ATTR{type}=="1", NAME="lan2"
  '';

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.${externalInterface}.accept_ra" = 2;
  };

  homelab.motd.networkInterfaces = lib.mapAttrsToList (
    _: v: v.interface
  ) config.homelab.networks.local;

  networking = {
    hostName = "alison";
    domain = "${config.networking.hostName}.${vars.domainName}";
    nameservers = [ "127.0.0.1" ];
    hosts = lib.mkForce {
      "127.0.0.1" = [ "localhost" ];
      "::1" = [ "localhost" ];
    };
    bridges = {
      br0.interfaces = [
        "lan0"
        "lan1"
      ];
      br1.interfaces = [
        "lan2"
        "guest"
      ];
    };
    vlans = {
      iot = {
        interface = "${networks.lan.interface}";
        id = 3;
      };
      app = {
        interface = "${networks.lan.interface}";
        id = 4;
      };
      guest = {
        interface = "${networks.lan.interface}";
        id = 5;
      };
    };
    interfaces = {
      ${externalInterface} = {
        useDHCP = true;
      };
      ${networks.lan.interface} = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "${networks.lan.cidr}";
            prefixLength = 24;
          }
        ];
      };
      ${networks.iot.interface} = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "${networks.iot.cidr}";
            prefixLength = 24;
          }
        ];
      };
      ${networks.app.interface} = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "${networks.app.cidr}";
            prefixLength = 24;
          }
        ];
      };
      ${networks.guest.interface} = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "${networks.guest.cidr}";
            prefixLength = 24;
          }
        ];
      };
    };
    nat = {
      enable = true;
      externalInterface = externalInterface;
      internalIPs = internalIPs;
      internalInterfaces = internalInterfaces;
    };
    enableIPv6 = true;

    dhcpcd = {
      persistent = true;
      extraConfig = ''
        noipv6rs
        interface ${externalInterface}
        ia_na 1
        ia_pd 2/::/60 ${networks.lan.interface}/0/64 ${networks.iot.interface}/1/64 ${networks.guest.interface}/2/64 ${networks.app.interface}/4/64
        vendorclassid nixos
      '';
    };

  };

  environment.systemPackages = with pkgs; [
    tcpdump
    dnsutils
  ];

  systemd.services.kea-dhcp4-server = {
    wants =
      (lib.mapAttrsToList (_: val: (val.interface + "-netdev.service")) (
        lib.attrsets.filterAttrs (n: v: v.dhcp) networks
      ))
      ++ [
        "network-pre.target"
      ];
    after = config.systemd.services.kea-dhcp4-server.wants;
  };
  services = {
    avahi = {
      enable = true;
      allowInterfaces = internalInterfaces;
      reflector = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
    kea = {
      dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = lib.mapAttrsToList (_: val: val.interface) (
              lib.attrsets.filterAttrs (n: v: v.dhcp) networks
            );
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          option-data = [
            {
              name = "domain-name-servers";
              data = "${networks.lan.cidr}";
              always-send = true;
            }
            {
              name = "routers";
              data = "${networks.lan.cidr}";
            }
            {
              name = "domain-name";
              data = "${vars.domainName}";
            }
          ];

          rebind-timer = 2000;
          renew-timer = 1000;
          valid-lifetime = 43200;

          subnet4 =
            lib.lists.forEach
              (lib.attrsets.mapAttrsToList (name: value: name) (lib.attrsets.filterAttrs (n: v: v.dhcp) networks))
              (x: {
                id = (
                  lib.attrsets.getAttrFromPath [
                    x
                    "id"
                  ] networks
                );
                pools = [
                  {
                    pool =
                      toString (
                        (lib.strings.removeSuffix ".1" (
                          lib.attrsets.getAttrFromPath [
                            x
                            "cidr"
                          ] networks
                        ))
                        + ".100"
                      )
                      + " - "
                      + (
                        (lib.strings.removeSuffix ".1" (
                          lib.attrsets.getAttrFromPath [
                            x
                            "cidr"
                          ] networks
                        ))
                        + ".255"
                      );
                  }
                ];
                option-data = [
                  {
                    name = "domain-name-servers";
                    data = (
                      lib.attrsets.getAttrFromPath [
                        x
                        "cidr"
                      ] networks
                    );
                    always-send = true;
                  }
                  {
                    name = "routers";
                    data = (
                      lib.attrsets.getAttrFromPath [
                        x
                        "cidr"
                      ] networks
                    );
                  }
                ];
                subnet =
                  (lib.strings.removeSuffix ".1" (
                    lib.attrsets.getAttrFromPath [
                      x
                      "cidr"
                    ] networks
                  ))
                  + ".0/24";
                reservations = (
                  lib.attrsets.getAttrFromPath [
                    x
                    "reservations"
                  ] networks
                );
              });
        };
      };
    };

    radvd = {
      enable = true;
      config = lib.concatStrings (
        lib.lists.forEach
          (lib.attrsets.mapAttrsToList (name: value: name) (lib.attrsets.filterAttrs (n: v: v.dhcp) networks))
          (
            x:
            (lib.concatMapStrings (x: "${x}\n") [
              (lib.concatStrings [
                "interface "
                (lib.attrsets.getAttrFromPath [
                  x
                  "interface"
                ] networks)
              ])
              ''
                {
                  AdvSendAdvert on;
                  prefix ::/64
                  {
                    AdvOnLink on;
                    AdvAutonomous on;
                  };
                };
              ''
            ])
          )
      );
    };
    journald = {
      rateLimitBurst = 0;
      extraConfig = "SystemMaxUse=50M";
    };
  };
}
