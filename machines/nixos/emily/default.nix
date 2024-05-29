{ inputs, lib, config, vars, pkgs, ... }:
{
  boot.kernelModules = [ "nct6775" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  boot.zfs.forceImportRoot = true;
  motd.networkInterfaces = lib.lists.singleton "enp1s0f0";
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
    ./backup
    ./shares ];

  powerManagement.powertop.enable = true;

  services.hddfancontrol = {
    enable = true;
    disks = [
     "/dev/disk/by-label/Data1"
     "/dev/disk/by-label/Data2"
     "/dev/disk/by-label/Parity1"
    ];
    pwmPaths = [
    "/sys/class/hwmon/hwmon0/pwm3"
    ];
    extraArgs = [
      "--pwm-start-value=100"
      "--pwm-stop-value=50"
      "--smartctl"
      "-i 30"
      "--spin-down-time=900"
    ];
  };

  networking = {
  useDHCP = true;
  networkmanager.enable = false;
  firewall = {
  allowPing = true;
  trustedInterfaces = [ "enp1s0f0" ];
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
