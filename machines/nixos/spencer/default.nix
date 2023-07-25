{ modulesPath, machines, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };

  zramSwap.enable = false;


  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 2048;
  } ];

  networking = {
    hostName = "spencer";
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
    defaultGateway = {
      address = machines.spencer.gateway;
      interface = "ens3";
    };  
    interfaces = {    
      ens3.ipv4 = {    
        addresses = [{      
          address = machines.spencer.address;
          prefixLength = 25;
        }];    
      };
    };
  };
}
