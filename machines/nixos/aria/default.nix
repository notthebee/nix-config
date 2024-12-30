{
  lib,
  config,
  pkgs,
  ...
}:
{
  boot.kernelModules = [ "nct6775" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  boot.zfs.forceImportRoot = true;
  motd.networkInterfaces = lib.lists.singleton config.homelab.networks.external.aria.interface;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "ata-SAMSUNG_MZ7LN256HAJQ-00000_S3TWNX0N158949" ];
      immutable = false;
      availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "sd_mod"
        "sr_mod"
      ];
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
    ./syncthing
    ./backup
    ./shares
    ../../networks.nix
  ];

  services.auto-aspm.enable = true;
  services.hddfancontrol = {
    enable = true;
    disks = [
      "/dev/disk/by-label/Data1"
      "/dev/disk/by-label/Data2"
      "/dev/disk/by-label/Data3"
      "/dev/disk/by-label/Data4"
      "/dev/disk/by-label/Parity1"
    ];
    pwmPaths = [ "/sys/class/hwmon/hwmon0/pwm2" ];
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

  homelab = {
    enable = true;
    cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
    baseDomain = "aria.goose.party";
    timeZone = "Europe/Berlin";
    mounts = {
      slow = "/mnt/mergerfs_slow";
      fast = "/mnt/user";
      config = "/persist/opt/services";
    };
    services = {
      backup = {
        enable = true;
        passwordFile = config.age.secrets.resticPassword.path;
        s3.enable = true;
        s3.environmentFile = config.age.secrets.resticBackblazeEnv.path;
        local.enable = false;
      };
      enable = true;
      immich.enable = true;
    };
  };

}
