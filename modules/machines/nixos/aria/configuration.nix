{
  config,
  pkgs,
  lib,
  ...
}:
let
  hardDrives = [
    "/dev/disk/by-label/Data1"
    "/dev/disk/by-label/Data2"
    "/dev/disk/by-label/Data3"
    "/dev/disk/by-label/Data4"
    "/dev/disk/by-label/Parity1"
  ];
in
{
  boot.kernelModules = [ "nct6775" ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  boot.zfs.forceImportRoot = true;
  boot.kernelParams = [
    "pcie_aspm=force"
    "consoleblank=60"
  ];
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "ata-SAMSUNG_MZ7LN256HAJQ-00000_S3TWNX0N158949" ];
      immutable = true;
      availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "sd_mod"
        "sr_mod"
      ];
      removableEfi = true;
    };
  };

  imports = [
    ../../../misc/zfs-root
    ../../../misc/agenix
    ../../../misc/tailscale
    ./filesystems
    ./syncthing
    ./backup
    ./homelab
    ./secrets
  ];

  services.autoaspm.enable = true;
  systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart =
        let
          idleTime = toString 900;
          hardDriveParameter = lib.strings.concatMapStringsSep " " (x: "-a ${x} -i ${idleTime}") hardDrives;
        in
        "${pkgs.hd-idle}/bin/hd-idle -i 0 ${hardDriveParameter}";
    };
  };

  services.hddfancontrol = {
    enable = true;
    settings = {
      harddrives = {
        disks = hardDrives;
        pwmPaths = [ "/sys/class/hwmon/hwmon0/pwm1:30:22" ];
        extraArgs = [
          "-i 30sec"
        ];
      };
    };
  };

  networking = {
    useDHCP = true;
    networkmanager.enable = false;
    hostName = "aria";
    hostId = "35cd8bc5";
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true;
  powerManagement.powertop.enable = true;

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

  tg-notify = {
    enable = true;
    credentialsFile = config.age.secrets.tgNotifyCredentials.path;
  };
}
