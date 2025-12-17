{
  modulesPath,
  lib,
  config,
  ...
}:
let
  net = config.homelab.networks;
  mainNet = net.external.spencer;
  wg0Net = net.local.wireguard-ext;
in
{
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0,115200"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  fileSystems."/boot/EFI" = {
    device = "/dev/sda15";
    fsType = "vfat";
  };

  zramSwap.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048;
    }
  ];

  imports = [
    ../../../misc/notthebe.ee
    ../../../misc/agenix
    ./secrets.nix
    ./homelab.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg0" = {
        wireguardConfig = {
          ListenPort = 51820;
          PrivateKeyFile = config.age.secrets.wireguardPrivateKeySpencer.path;
        };
        wireguardPeers =
          let
            wgIp =
              proto: x:
              (
                (lib.strings.removeSuffix ".1" wg0Net.cidr.${proto})
                + (if proto == "v6" then "${toString x}/128" else ".${toString x}/32")
              );
          in
          [
            {
              # emily
              PublicKey = "npTrLwAIJZ3m4XqdmQpP/KIi0C6urjBQHoCuA1vOOTc=";
              AllowedIPs = [
                (wgIp "v4" 2)
                (wgIp "v6" 2)
              ];
            }
            {
              # meredith
              PublicKey = "qbSQWspWHmucDmU/BsrXpcVF+txPETo4c74/tGkE4C0=";
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
    networks = {
      "60-wg0" = {
        matchConfig.Name = "wg0";
        networkConfig = lib.mkMerge [
          {
            IPMasquerade = "both";
            Address = [
              "${wg0Net.cidr.v4}/24"
              "${wg0Net.cidr.v6}1/64"
            ];
          }
        ];
      };
      "10-wan0" = {
        matchConfig.Driver = "virtio_net";
        networkConfig = {
          Address = lib.lists.remove null [
            mainNet.v4.address
            mainNet.v6.address
          ];
          DNS = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
            "2620:fe::fe#dns.quad9.net"
            "2620:fe::9#dns.quad9.net"
          ];
          DNSSEC = true;
          DNSOverTLS = true;
          IPv6AcceptRA = true;
          IPv6SendRA = false;
          LinkLocalAddressing = "ipv6";
          Gateway = lib.lists.remove null [
            mainNet.v4.gateway
            mainNet.v6.gateway
          ];
        };
        dhcpV6Config = {
          WithoutRA = "solicit";
          UseDelegatedPrefix = false;
          UseHostname = false;
          UseDNS = false;
          UseNTP = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
  networking = {
    useDHCP = false;
    hostName = "spencer";
    nat.enable = false;
    firewall = {
      enable = true;
      allowedUDPPorts = [ 51820 ];
    };
  };
  services.openssh = {
    openFirewall = true;
  };

}
