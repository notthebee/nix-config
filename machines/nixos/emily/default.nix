{ inputs, lib, config, vars, pkgs, ... }:
{
  boot.initrd.kernelModules = [ "i915" ];
  hardware.cpu.intel.updateMicrocode = true;                                                                                                                                                                         
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

  networking.firewall.allowedTCPPorts = [ 
  5201 # iperf3 
  ];

  virtualisation.docker.storageDriver = "overlay2";

  systemd.services.mergerfs-uncache.serviceConfig.ExecStart = lib.mkForce "/run/current-system/sw/bin/mergerfs-uncache -s ${vars.cacheArray} -d ${vars.slowArray} -t 50 --exclude 'YoutubeCurrent'";

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
