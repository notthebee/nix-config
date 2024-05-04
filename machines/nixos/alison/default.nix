{ inputs, lib, config, vars, pkgs, ... }:
{
  boot.kernelModules = [ "i915" "cp210x" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  boot.zfs.forceImportRoot = true;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [  "nvme-WD_BLACK_SN770_500GB_22453P805347" ];
      immutable = false;
      availableKernelModules = [  "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
      removableEfi = true;
      kernelParams = [ 
      "pcie_aspm=force"
      "consoleblank=60"
      ];
      sshUnlock = {
        enable = false;
        authorizedKeys = [ ];
      };
    };
  networking = {
    hostName = "alison";
    hostId = "73cd46a7";
   };
  };


  imports = [
    ./containerOverrides
    ./router
    ./filesystems
  ];

  #powerManagement.powertop.enable = true;

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true; 

  services.duckdns = {
    enable = true;
    domainsFile = config.age.secrets.duckDNSDomain.path;
    tokenFile = config.age.secrets.duckDNSToken.path;
  };
  users = {
  groups.share = {
    gid = 993;
  };
  users.share = {
    uid = 994;
    isSystemUser = true;
    group = "share";
  };
  };

  environment.systemPackages = with pkgs; [
    pciutils
    smartmontools
    powertop
    cpufrequtils
    gnumake
    gcc
  ];
  }
