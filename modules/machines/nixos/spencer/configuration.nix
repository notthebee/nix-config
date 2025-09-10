{ modulesPath, config, ... }:
let
  net = config.homelab.networks.external.spencer;
in
{
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
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
    ./matrix.nix
    ./wireguard.nix
    ./secrets.nix
    ./plausible.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking = {
    hostName = "spencer";
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
    defaultGateway = {
      address = net.gateway;
      interface = net.interface;
    };
    interfaces = {
      "${net.interface}".ipv4 = {
        addresses = [
          {
            address = net.address;
            prefixLength = 25;
          }
        ];
      };
    };
  };
}
