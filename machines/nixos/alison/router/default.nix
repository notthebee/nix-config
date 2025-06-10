{
  lib,
  config,
  vars,
  ...
}:
let
  networks = config.homelab.networks.local;
  internalInterfaces = lib.attrsets.mapAttrsToList (_: val: val.interface) networks;
  dhcpLeases = x: lib.attrsets.mapAttrsToList (_: value: value) networks.${x}.reservations;
  dnsCfg = x: {
    DNS = (
      lib.lists.remove null [
        networks.${x}.cidr.v4
        networks.${x}.cidr.v6
      ]
    );
    DNSSEC = false;
    DNSOverTLS = false;
  };
  dhcpCfgCommon = x: {
    EmitRouter = true;
    EmitDNS = true;
    DNS = networks.${x}.cidr.v4;
    EmitNTP = true;
    NTP = networks.${x}.cidr.v4;
    PoolOffset = 100;
    ServerAddress = "${networks.${x}.cidr.v4}/24";
    UplinkInterface = "wan0";
    DefaultLeaseTimeSec = 1800;
  };
  dhcpCfgDualStack = x: {
    dhcpServerConfig = (dhcpCfgCommon x);
    ipv6Prefixes = [ { Prefix = "${networks.${x}.cidr.v6}/64"; } ];
    ipv6SendRAConfig = {
      DNS = "${networks.${x}.cidr.v6}";
      EmitDNS = true;
      EmitDomains = false;
    };
    networkConfig = lib.mkMerge [
      {
        IPv6AcceptRA = false;
        IPv6SendRA = true;
        LinkLocalAddressing = "ipv6";
        DHCPPrefixDelegation = true;
        DHCPServer = true;
        Address = [
          "${networks.${x}.cidr.v4}/24"
          "${networks.${x}.cidr.v6}/64"
        ];
        IPv4Forwarding = true;
        IPMasquerade = "ipv4";
      }
      (dnsCfg x)
    ];
    dhcpServerStaticLeases = (dhcpLeases x);

  };
  dhcpCfgIPv4Only = x: {
    dhcpServerConfig = (dhcpCfgCommon x);
    dhcpServerStaticLeases = (dhcpLeases x);
    networkConfig = lib.mkMerge [
      {
        DHCPServer = true;
        Address = "${networks.${x}.cidr.v4}/24";
        IPv4Forwarding = true;
        IPMasquerade = "ipv4";
      }
      (dnsCfg x)
    ];
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
    config.networkConfig.IPv6Forwarding = true;
    networks = {
      "10-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          DHCP = true;
          IPv6AcceptRA = true;
          LinkLocalAddressing = "ipv6";
          IPv4Forwarding = true;
          DNS = "127.0.0.1";
          DNSSEC = false;
          DNSOverTLS = false;
        };
        dhcpV4Config = {
          UseHostname = false;
          UseDNS = false;
          UseNTP = false;
          UseSIP = false;
          ClientIdentifier = "mac";
          UseRoutes = false;
          UseGateway = true;
        };
        ipv6AcceptRAConfig = {
          UseDNS = false;
          DHCPv6Client = true;
        };
        dhcpV6Config = {
          WithoutRA = "solicit";
          UseDelegatedPrefix = true;
          UseHostname = false;
          UseDNS = false;
          UseNTP = false;
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
          linkConfig.RequiredForOnline = false;
        }
        (dhcpCfgIPv4Only "iot")
      ];
      "30-guest" = {
        matchConfig.Name = "guest";
        networkConfig.Bridge = "br1";
        linkConfig.RequiredForOnline = false;
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
          linkConfig.RequiredForOnline = false;
        }
        (dhcpCfgDualStack "guest")
      ];
      "60-wg0" = {
        matchConfig.Name = "wg0";
        networkConfig = lib.mkMerge [
          {
            IPMasquerade = "both";
            Address = [
              "${networks.wireguard.cidr.v4}/24"
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
        wireguardPeers =
          let
            wgIp =
              proto: x:
              (
                (lib.strings.removeSuffix ".1" networks.wireguard.cidr.${proto})
                + ".${toString x}"
                + (if proto == "v6" then "/128" else "/32")
              );
          in
          [
            {
              # meredith
              PublicKey = "rAkXoiMoxwsKaZc4qIpoXWxD9HBCYjsAB33hPB7jBBg=";
              AllowedIPs = [
                (wgIp "v4" 2)
                (wgIp "v6" 2)
              ];
            }
            {
              # iphone
              PublicKey = "6Nh1FrZLJBv7kb/jlR+rkCsWDoiSq9jpOQo68a6vr0Q=";
              AllowedIPs = [
                (wgIp "v4" 3)
                (wgIp "v6" 3)
              ];
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
    domain = "${config.networking.hostName}.${config.homelab.baseDomain}";
    search = [ config.homelab.baseDomain ];
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
