{ modulesPath, ... }: {
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
      address = "5.2.65.129";
      interface = "ens3";
    };  
    interfaces = {    
      ens3.ipv4 = {    
        addresses = [{      
          address = "5.2.76.41";      
          prefixLength = 25;    
        }];    
      };
    };
  };
}
