{ modulesPath, config, ... }:
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
    ./matrix.nix
    ./wireguard.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking = {
    hostName = "spencer";
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
    defaultGateway = {
      address = config.homelab.networks.external.spencer.gateway;
      interface = "ens3";
    };
    interfaces = {
      ens3.ipv4 = {
        addresses = [
          {
            address = config.homelab.networks.external.spencer.address;
            prefixLength = 25;
          }
        ];
      };
    };
  };
}
