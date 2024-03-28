{ inputs, lib, config, vars, pkgs, ... }:
{
  #boot.kernelModules = [ "nct6775" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  boot.zfs.forceImportRoot = true;
  #motd.networkInterfaces = lib.lists.singleton "enp1s0f0";
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      # TODO
      bootDevices = [  "ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K" ];
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
      hostName = "aria";
      timeZone = "Europe/Berlin";
      hostId = "35cd8bc5";
    };
  };

  imports = [
    ./filesystems
    ./shares ];

  powerManagement.powertop.enable = true;

  systemd.services.hd-idle = {
    description = "HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 900";
    };
  };

  networking = {
  useDHCP = true;
  networkmanager.enable = false;
  firewall = {
  allowPing = true;
  allowedTCPPorts = [ 5201 ];
  };
  nameservers = [ "192.168.178.1" ];
  defaultGateway = "192.168.178.1";
  interfaces = {
    enp1s0f0.ipv4 = {
    addresses = [{
      address = "192.168.178.230";
      prefixLength = 24;
    }];
    routes = [{
      address = "192.168.178.0";
      prefixLength = 24;
      via = "192.168.178.1";
    }];
  };
    };
};

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true; 

  environment.systemPackages = with pkgs; [
    pciutils
    glances
    hdparm
    hd-idle
    hddtemp
    smartmontools
    powertop
    cpufrequtils
    gnumake
    gcc
    intel-gpu-tools
  ];
  
  }
