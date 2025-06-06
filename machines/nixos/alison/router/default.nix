{
  lib,
  config,
  vars,
  ...
}:
let
  networks = config.homelab.networks.local;
  internalInterfaces = lib.mapAttrsToList (_: val: val.interface) networks;
  dhcpLeases =
    x: lib.lists.forEach networks.${x}.reservations (y: builtins.removeAttrs y [ "Hostname" ]);
in
{
  imports = [
    ./firewall.nix
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:57", ATTR{type}=="1", NAME="wan0"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:56", ATTR{type}=="1", NAME="lan0"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:55", ATTR{type}=="1", NAME="lan1"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:54", ATTR{type}=="1", NAME="lan2"
  '';

  homelab.motd.networkInterfaces = lib.mapAttrsToList (_: v: v.interface) networks;

  networking.useDHCP = false;

  systemd.network =
    let
      dns4 = "1.1.1.1 9.9.9.9";
      dns6 = "2606:4700:4700::1111 2620:fe::fe";

      dnsCfg = {
        DNS = "${dns6} ${dns4}";
        DNSSEC = "yes";
        DNSOverTLS = "yes";
      };
    in
    {
      enable = true;
      config.networkConfig.IPv6Forwarding = "yes";
      networks = {
        "10-wan0" = {
          matchConfig.Name = "wan0";
          networkConfig = lib.mkMerge [
            {
              DHCP = "yes";
              IPv6AcceptRA = "yes";
              LinkLocalAddressing = "ipv6";
              IPv4Forwarding = "yes";
            }
            dnsCfg
          ];

          dhcpV4Config = {
            UseHostname = "no";
            UseDNS = "no";
            UseNTP = "no";
            UseSIP = "no";
            UseRoutes = "no";
            UseGateway = "yes";
          };

          ipv6AcceptRAConfig = {
            UseDNS = "no";
            DHCPv6Client = "yes";
          };
          dhcpV6Config = {
            WithoutRA = "solicit";
            UseDelegatedPrefix = true;
            UseHostname = "no";
            UseDNS = "no";
            UseNTP = "no";
          };
          linkConfig.RequiredForOnline = "routable";
        };
        "20-lan0" = {
          matchConfig.Name = "lan0";
          networkConfig.Bridge = "br0";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "20-lan1" = {
          matchConfig.Name = "lan1";
          networkConfig.Bridge = "br0";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "20-lan2" = {
          matchConfig.Name = "lan2";
          networkConfig.Bridge = "br1";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "30-iot" = {
          matchConfig.Name = "iot";
          dhcpServerConfig = {
            EmitRouter = "yes";
            EmitDNS = "yes";
            DNS = "${dns4}";
            EmitNTP = "yes";
            NTP = networks.iot.cidr;
            PoolOffset = 100;
            ServerAddress = "${networks.iot.cidr}/24";
            UplinkInterface = "wan0";
            DefaultLeaseTimeSec = 1800;
          };
          linkConfig.RequiredForOnline = "no";
          networkConfig = {
            DHCPServer = "yes";
            Address = "${networks.iot.cidr}/24";
            IPv4Forwarding = "yes";
            IPMasquerade = "ipv4";
          };
          dhcpServerStaticLeases = dhcpLeases "iot";
        };
        "30-guest" = {
          matchConfig.Name = "guest";
          networkConfig.Bridge = "br1";
          linkConfig.RequiredForOnline = "no";
        };
        "40-br0" = {
          matchConfig.Name = "br0";
          vlan = [
            "iot"
            "guest"
          ];
          dhcpServerConfig = {
            EmitRouter = "yes";
            EmitDNS = "yes";
            DNS = "${dns4}";
            EmitNTP = "yes";
            NTP = networks.lan.cidr;
            PoolOffset = 100;
            ServerAddress = "${networks.lan.cidr}/24";
            UplinkInterface = "wan0";
            DefaultLeaseTimeSec = 1800;
          };
          linkConfig.RequiredForOnline = "routable";
          ipv6SendRAConfig = {
            EmitDNS = "yes";
            DNS = dns6;
            EmitDomains = "no";
          };
          networkConfig = lib.mkMerge [
            {
              IPv6AcceptRA = "no";
              IPv6SendRA = "yes";
              LinkLocalAddressing = "ipv6";
              DHCPPrefixDelegation = "yes";
              DHCPServer = "yes";
              Address = "${networks.lan.cidr}/24";
              IPv4Forwarding = "yes";
              IPMasquerade = "ipv4";
            }
            dnsCfg
          ];
          dhcpServerStaticLeases = dhcpLeases "lan";
          dhcpPrefixDelegationConfig.SubnetId = "0x1";
        };
        "40-br1" = {
          matchConfig.Name = "br1";
          dhcpServerConfig = {
            EmitRouter = "yes";
            EmitDNS = "yes";
            DNS = "${dns4}";
            EmitNTP = "yes";
            NTP = networks.guest.cidr;
            PoolOffset = 100;
            ServerAddress = "${networks.guest.cidr}/24";
            UplinkInterface = "wan0";
            DefaultLeaseTimeSec = 1800;
          };
          linkConfig.RequiredForOnline = "no";
          ipv6SendRAConfig = {
            EmitDNS = "yes";
            DNS = dns6;
            EmitDomains = "no";
          };
          networkConfig = lib.mkMerge [
            {
              IPv6AcceptRA = "no";
              IPv6SendRA = "yes";
              LinkLocalAddressing = "ipv6";
              DHCPPrefixDelegation = "yes";
              DHCPServer = "yes";
              Address = "${networks.guest.cidr}/24";
              IPv4Forwarding = "yes";
              IPMasquerade = "ipv4";
            }
            dnsCfg
          ];
          dhcpServerStaticLeases = dhcpLeases "guest";
        };
        "60-wg0" = {
          matchConfig.Name = "wg0";
          networkConfig = lib.mkMerge [
            {
              IPMasquerade = "both";
              Address = networks.wireguard.cidr + "/24";
            }
            dnsCfg
          ];
        };
      };
      netdevs = {
        # Create the bridge interface
        "50-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
          };
        };
        "50-br1" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br1";
          };
        };
        "50-iot" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "iot";
          };
          vlanConfig.Id = 3;
        };
        "50-guest" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "guest";
          };
          vlanConfig.Id = 5;
        };
        "50-wg0" = {
          wireguardConfig = {
            ListenPort = 51820;
            PrivateKeyFile = config.age.secrets.wireguardPrivateKeyAlison.path;
          };
          wireguardPeers = [
            {
              # meredith
              PublicKey = "rAkXoiMoxwsKaZc4qIpoXWxD9HBCYjsAB33hPB7jBBg=";
              AllowedIPs = [ (lib.strings.removeSuffix ".1" networks.wireguard.cidr + ".2/32") ];
            }
            {
              # iphone
              PublicKey = "6Nh1FrZLJBv7kb/jlR+rkCsWDoiSq9jpOQo68a6vr0Q=";
              AllowedIPs = [ (lib.strings.removeSuffix ".1" networks.wireguard.cidr + ".3/32") ];
            }
          ];
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
          };
        };
      };
    };
  networking = {
    hostName = "alison";
    domain = "${config.networking.hostName}.${vars.domainName}";
    search = [ vars.domainName ];
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
    journald = {
      rateLimitBurst = 0;
      extraConfig = "SystemMaxUse=50M";
    };
  };
}
