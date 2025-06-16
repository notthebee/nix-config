{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  hl = config.homelab;
  lan = hl.networks.local.lan;
  emilyIpAddress = lan.reservations.emily.Address;
  gatewayIpAddress = lan.cidr.v4;
  hardDrives = [
    "/dev/disk/by-label/Data1"
    "/dev/disk/by-label/Data2"
    "/dev/disk/by-label/Data3"
    "/dev/disk/by-label/Parity1"
  ];
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
        intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
        vpl-gpu-rt # QSV on 11th gen or newer
      ];
    };
  };
  boot = {
    zfs.forceImportRoot = true;
    kernelParams = [
      "pcie_aspm=force"
      "consoleblank=60"
      "acpi_enforce_resources=lax"
    ];
    kernelModules = [
      "coretemp"
      "jc42"
      "lm78"
      "f71882fg"
    ];
  };

  networking = {
    useDHCP = true;
    networkmanager.enable = false;
    hostName = "emily";
    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = emilyIpAddress;
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = gatewayIpAddress;
      interface = "enp1s0";
    };
    hostId = "0730ae51";
    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [
        "enp1s0"
        "tailscale0"
      ];
    };
  };
  zfs-root = {
    boot = {
      partitionScheme = {
        biosBoot = "-part4";
        efiBoot = "-part1";
        bootPool = "-part2";
        rootPool = "-part3";
      };
      bootDevices = [ "nvme-WDC_PC_SN530_SDBPMPZ-256G-1101_221368801205" ];
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
    ./filesystems
    ./backup
    ./homelab
    ./secrets
  ];

  services.duckdns = {
    enable = true;
    domainsFile = config.age.secrets.duckDNSDomain.path;
    tokenFile = config.age.secrets.duckDNSToken.path;
  };

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
        pwmPaths = [ "/sys/class/hwmon/hwmon2/device/pwm2:50:50" ];
        extraArgs = [
          "-i 30sec"
        ];
      };
    };
  };

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true;

  services.mover = {
    enable = true;
    cacheArray = hl.mounts.fast;
    backingArray = hl.mounts.slow;
    user = hl.user;
    group = hl.group;
    percentageFree = 60;
    excludedPaths = [
      "Media/Music"
      "Media/Photos"
      "YoutubeCurrent"
      "Downloads.tmp"
      "Media/Kiwix"
      "Documents"
      "TimeMachine"
      ".DS_Store"
      ".cache"
    ];
  };

  services.auto-aspm.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
    glances
    hdparm
    hd-idle
    hddtemp
    smartmontools
    cpufrequtils
    intel-gpu-tools
    powertop
  ];

  tg-notify = {
    enable = true;
    credentialsFile = config.age.secrets.tgNotifyCredentials.path;
  };

  services.adiosBot = {
    enable = true;
    botTokenFile = config.age.secrets.adiosBotToken.path;
  };
}
