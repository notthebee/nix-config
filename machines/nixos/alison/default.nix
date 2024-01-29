{ inputs, lib, config, vars, pkgs, ... }:
{
  boot.kernelModules = [ "i915" ];
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
    ./router
    ./filesystems
  ];

  #powerManagement.powertop.enable = true;

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true; 

  environment.systemPackages = with pkgs; [
    pciutils
    smartmontools
    powertop
    cpufrequtils
    gnumake
    gcc
  ];
  }
