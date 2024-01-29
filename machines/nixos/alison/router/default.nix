{ lib, config, pkgs, vars, ... }:
let
  externalInterface = "enp2s0";
  internalInterfaces = lib.mapAttrsToList (_: val: val.interface) config.networks;
  internalIPs = lib.mapAttrsToList (_: val: lib.strings.removeSuffix ".1" val.cidr + ".0/24") config.networks;
in {

  imports = [
    ./dns.nix
    ./firewall.nix
    ../../../networksLocal.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.${externalInterface}.accept_ra" = 2;
  };

  networking = {
    hostName = "alison";
    domain = "alison.goose.party";
    nameservers = [
      "127.0.0.1"
    ];
    hosts = lib.mkForce {
      "127.0.0.1" = [ "localhost" ];
      "::1" = [ "localhost" ];
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
    dnsmasq = {
      enable = true;
      settings = {
        server = [ "127.0.0.1#10053" ];
        address = [
          (lib.concatStrings [
            (lib.concatMapStrings (x: "/" + x) [
              vars.domainName
              (lib.lists.findFirst (x: x.hostname == "emily") "127.0.0.1" config.networks.lan.reservations).ip-address
            ])
          ])
        ];
      };
    };
    kea = {
      dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = {
          interfaces = internalInterfaces;
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
            lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) config.networks) (x:
            {
              pools = [
              {
                pool = toString ((lib.strings.removeSuffix ".1" (lib.attrsets.getAttrFromPath [x "cidr"] config.networks)) + ".100") + " - " + ((lib.strings.removeSuffix ".1" (lib.attrsets.getAttrFromPath [x "cidr"] config.networks)) + ".255");
              }
              ];
              option-data = [
              {
                name = "routers";
                data = (lib.attrsets.getAttrFromPath [x "cidr"] config.networks);
              }];
              subnet = (lib.strings.removeSuffix ".1" (lib.attrsets.getAttrFromPath [x "cidr"] config.networks)) + ".0/24";
              reservations = (lib.attrsets.getAttrFromPath [x "reservations"] config.networks);
            });
        };
      };
    };

      radvd = {
        enable = true;
        config =
        lib.concatStrings (lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) config.networks) (x:
        (lib.concatMapStrings (x: "${x}\n") [
        (lib.concatStrings [
        "interface "
        (lib.attrsets.getAttrFromPath [x "interface"] config.networks)
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
      prometheus.exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            "tcpstat"
            "conntrack"
            "diskstats"
            "entropy"
            "filefd"
            "filesystem"
            "loadavg"
            "meminfo"
            "netdev"
            "netstat"
            "stat"
            "time"
            "vmstat"
            "logind"
            "interrupts"
            "ksmd"
          ];
        };
      };
    };
    }

