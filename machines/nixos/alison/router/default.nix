{ lib, config, pkgs, vars, ... }:
let
  externalInterface = "enp2s0";
  internalInterfaces = lib.mapAttrsToList (_: val: val.interface) config.networks;
  internalIPs = lib.mapAttrsToList (_: val: lib.strings.removeSuffix ".1" val.cidr + ".0/24") config.networks;
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
    ../../../networksLocal.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.${externalInterface}.accept_ra" = 2;
  };

  networking = {
    hostName = "alison";
    domain = "${config.networking.hostName}.${vars.domainName}";
    nameservers = [
      "127.0.0.1"
    ];
    hosts = lib.mkForce {
      "127.0.0.1" = [ "localhost" ];
      "::1" = [ "localhost" ];
    };
    bridges = {
      br0.interfaces = [ "enp1s0" "eno1" ];
      br1.interfaces = [ "enp4s0" "guest" ];
    };
    vlans = {
      iot = {
        interface = "${config.networks.lan.interface}";
        id = 3;
      };
      app = {
        interface = "${config.networks.lan.interface}";
        id = 4;
      };
      guest = {
        interface = "${config.networks.lan.interface}";
        id = 5;
      };
    };
    interfaces = {
      ${externalInterface} = {
        useDHCP = true;
      };
      ${config.networks.lan.interface} = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "${config.networks.lan.cidr}";
          prefixLength = 24;
        }];
      };
      ${config.networks.iot.interface} = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "${config.networks.iot.cidr}";
          prefixLength = 24;
        }];
      };
      ${config.networks.app.interface} = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "${config.networks.app.cidr}";
          prefixLength = 24;
        }];
      };
      ${config.networks.guest.interface} = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "${config.networks.guest.cidr}";
          prefixLength = 24;
        }];
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
        ia_pd 2/::/60 ${config.networks.lan.interface}/0/64 ${config.networks.iot.interface}/1/64 ${config.networks.guest.interface}/2/64 ${config.networks.app.interface}/4/64
        vendorclassid nixos
      '';
    };

  };

  environment.systemPackages = with pkgs; [
    tcpdump
    dnsutils
  ];

  systemd.services.kea-dhcp4-server = {
    wants = (lib.mapAttrsToList (_: val: (val.interface + "-netdev.service")) (lib.attrsets.filterAttrs (n: v: v.dhcp) config.networks)) ++ [ "guest-netdev.service" "network-pre.target" ];
    after = (lib.mapAttrsToList (_: val: (val.interface + "-netdev.service")) (lib.attrsets.filterAttrs (n: v: v.dhcp) config.networks)) ++ [ "guest-netdev.service" "network-pre.target" ];
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
            interfaces = (lib.mapAttrsToList (_: val: val.interface) (lib.attrsets.filterAttrs (n: v: v.dhcp) config.networks)) ++ [ "guest" ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          option-data = [
            {
              name = "domain-name-servers";
              data = "${config.networks.lan.cidr}";
              always-send = true;
            }
            {
              name = "routers";
              data = "${config.networks.lan.cidr}";
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
            lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) (lib.attrsets.filterAttrs (n: v: v.dhcp) config.networks)) (x:
              {
                pools = [
                  {
                    pool = toString ((lib.strings.removeSuffix ".1" (lib.attrsets.getAttrFromPath [ x "cidr" ] config.networks)) + ".100") + " - " + ((lib.strings.removeSuffix ".1" (lib.attrsets.getAttrFromPath [ x "cidr" ] config.networks)) + ".255");
                  }
                ];
                option-data = [
                  {
                    name = "domain-name-servers";
                    data = (lib.attrsets.getAttrFromPath [ x "cidr" ] config.networks);
                    always-send = true;
                  }
                  {
                    name = "routers";
                    data = (lib.attrsets.getAttrFromPath [ x "cidr" ] config.networks);
                  }
                ];
                subnet = (lib.strings.removeSuffix ".1" (lib.attrsets.getAttrFromPath [ x "cidr" ] config.networks)) + ".0/24";
                reservations = (lib.attrsets.getAttrFromPath [ x "reservations" ] config.networks);
              });
        };
      };
    };

    radvd = {
      enable = true;
      config =
        lib.concatStrings (lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) (lib.attrsets.filterAttrs (n: v: v.dhcp) config.networks)) (x:
          (lib.concatMapStrings (x: "${x}\n") [
            (lib.concatStrings [
              "interface "
              (lib.attrsets.getAttrFromPath [ x "interface" ] config.networks)
            ]
            )
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
          ]
          )));
    };
    journald = {
      rateLimitBurst = 0;
      extraConfig = "SystemMaxUse=50M";
    };
  };
}
