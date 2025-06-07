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
  dnsCfg = x: {
    DNS = (
      lib.lists.remove null [
        networks.${x}.cidr.v4
        networks.${x}.cidr.v6
      ]
    );
    DNSSEC = "no";
    DNSOverTLS = "no";
  };
  dhcpCfgCommon = x: {
    EmitRouter = "yes";
    EmitDNS = "yes";
    DNS = networks.${x}.cidr.v4;
    EmitNTP = "yes";
    NTP = networks.${x}.cidr.v4;
    PoolOffset = 100;
    ServerAddress = "${networks.${x}.cidr.v4}/24";
    UplinkInterface = "wan0";
    DefaultLeaseTimeSec = 1800;
  };
  dhcpCfgDualStack = x: {
    dhcpServerConfig = (dhcpCfgCommon x);
    ipv6SendRAConfig = {
      EmitDNS = "yes";
      DNS = networks.${x}.cidr.v6;
      EmitDomains = "no";
    };
    networkConfig = lib.mkMerge [
      {
        IPv6AcceptRA = "no";
        IPv6SendRA = "yes";
        LinkLocalAddressing = "ipv6";
        DHCPPrefixDelegation = "yes";
        DHCPServer = "yes";
        Address = [
          "${networks.${x}.cidr.v4}/24"
        ];
        IPv4Forwarding = "yes";
        IPMasquerade = "ipv4";
      }
      (dnsCfg x)
    ];
    dhcpServerStaticLeases = (dhcpLeases x);

  };
  dhcpCfgIPv4Only = x: {
    dhcpServerConfig = (dhcpCfgCommon x);
    dhcpServerStaticLeases = (dhcpLeases x);
    networkConfig = {
      DHCPServer = "yes";
      Address = "${networks.${x}.cidr.v4}/24";
      IPv4Forwarding = "yes";
      IPMasquerade = "ipv4";
    };
  };
in
{
  imports = [
    ./firewall.nix
    ./dns.nix
  ];
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:57", ATTR{type}=="1", NAME="wan0"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:56", ATTR{type}=="1", NAME="lan0"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:55", ATTR{type}=="1", NAME="lan1"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:e2:69:63:e7:54", ATTR{type}=="1", NAME="lan2"
  '';

  homelab.motd.networkInterfaces = lib.mapAttrsToList (_: v: v.interface) networks;

  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    config.networkConfig.IPv6Forwarding = "yes";
    networks = {
      "10-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = "yes";
          LinkLocalAddressing = "ipv6";
          IPv4Forwarding = "yes";
          DNS = "127.0.0.1";
          DNSSEC = "no";
          DNSOverTLS = "no";
        };

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
      "30-iot" = lib.mkMerge [
        {
          matchConfig.Name = "iot";
          linkConfig.RequiredForOnline = "no";
        }
        (dhcpCfgIPv4Only "iot")
      ];
      "30-guest" = {
        matchConfig.Name = "guest";
        networkConfig.Bridge = "br1";
        linkConfig.RequiredForOnline = "no";
      };
      "40-br0" = lib.mkMerge [
        {
          matchConfig.Name = "br0";
          vlan = [
            "iot"
            "guest"
          ];
          linkConfig.RequiredForOnline = "routable";
          dhcpPrefixDelegationConfig.SubnetId = "0x1";
        }
        (dhcpCfgDualStack "lan")
      ];
      "40-br1" = lib.mkMerge [
        {
          matchConfig.Name = "br1";
          linkConfig.RequiredForOnline = "no";
        }
        (dhcpCfgDualStack "guest")
      ];
      "60-wg0" = {
        matchConfig.Name = "wg0";
        networkConfig = lib.mkMerge [
          {
            IPMasquerade = "both";
            Address = [
              "${networks.wireguard.cidr.v4}/24}"
              "${networks.wireguard.cidr.v6}/64"
            ];
          }
        ];
      };
    };
    netdevs = {
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
            AllowedIPs = [ (lib.strings.removeSuffix ".1" networks.wireguard.cidr.v4 + ".2/32") ];
          }
          {
            # iphone
            PublicKey = "6Nh1FrZLJBv7kb/jlR+rkCsWDoiSq9jpOQo68a6vr0Q=";
            AllowedIPs = [ (lib.strings.removeSuffix ".1" networks.wireguard.cidr.v4 + ".3/32") ];
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
