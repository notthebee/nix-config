{ inputs, lib, config, vars, pkgs, ... }:
{
  boot.kernelModules = [ "nct6775" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  boot.zfs.forceImportRoot = true;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [  "ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K" ];
      immutable = false;
      availableKernelModules = [  "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
      removableEfi = true;
      kernelParams = [ 
      "pcie_aspm=force"
      "consoleblank=60"
      "amd_pstate=active"
      ];
      sshUnlock = {
        enable = false;
        authorizedKeys = [ ];
      };
    };
    networking = {
      hostName = "emily";
      timeZone = "Europe/Berlin";
      hostId = "0730ae51";
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
  nameservers = [ "192.168.2.1" ];
  defaultGateway = "192.168.2.1";
  interfaces = {
    enp1s0f0.ipv4 = {
    addresses = [{
      address = "192.168.2.230";
      prefixLength = 24;
    }];
    routes = [{
      address = "192.168.2.0";
      prefixLength = 24;
      via = "192.168.2.1";
    }];
  };
    };
};

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true; 

  mover = {
    cacheArray = vars.cacheArray;
    backingArray = vars.slowArray;
    percentageFree = 60;
    excludedPaths = [
      "YoutubeCurrent"
      "Media/Kiwix"
      "Documents"
      "TimeMachine"
      ".DS_Store"
    ];
  };

  environment.systemPackages = with pkgs; [
    pciutils
    glances
    hdparm
    hd-idle
    hddtemp
    smartmontools
    go
    gotools
    gopls
    go-outline
    gocode
    gopkgs
    gocode-gomod
    godef
    golint
    powertop
    cpufrequtils
    gnumake
    gcc
    intel-gpu-tools
  ];
  }
