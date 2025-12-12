{
  config,
  lib,
  pkgs,
  ...
}:
let
  hl = config.homelab;
  lan = hl.networks.local.lan;
  emilyIPAddress = lan.reservations.emily.Address;
  hardDrives = [
    "/dev/disk/by-label/Data1"
    "/dev/disk/by-label/Data2"
    "/dev/disk/by-label/Data3"
    "/dev/disk/by-label/Parity1"
  ];
in
{
  services.prometheus.exporters.shellyplug.targets = [
    "192.168.32.4"
  ];
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="68:05:ca:39:92:d8", ATTR{type}=="1", NAME="lan0"
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="68:05:ca:39:92:d9", ATTR{type}=="1", NAME="lan1"
  '';
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
        libva-vdpau-driver
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
      "nvme_core.default_ps_max_latency_us=50000"
    ];
    kernelModules = [
      "coretemp"
      "jc42"
      "lm78"
      "f71882fg"
    ];
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig = {
          DHCP = true;
          Address = emilyIPAddress;
          IPv6AcceptRA = true;
          LinkLocalAddressing = "ipv6";
        };
        dhcpV4Config = {
          UseHostname = false;
          UseDNS = true;
          UseNTP = true;
          UseSIP = false;
          ClientIdentifier = "mac";
        };
        ipv6AcceptRAConfig = {
          UseDNS = true;
          DHCPv6Client = true;
        };
        dhcpV6Config = {
          WithoutRA = "solicit";
          UseDelegatedPrefix = true;
          UseHostname = false;
          UseDNS = true;
          UseNTP = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
  networking = {
    useDHCP = false;
    hostName = "emily";
    hostId = "0730ae51";
    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [
        "lan1"
        "tailscale0"
      ];
    };
  };
  zfs-root = {
    boot = {
      partitionScheme = {
        biosBoot = "-part4";
        efiBoot = "-part2";
        bootPool = "-part1";
        rootPool = "-part3";
      };
      bootDevices = [
        "ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K"
        "ata-Samsung_SSD_870_EVO_250GB_S6PENL0T905657B"
      ];
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
    ../../../misc/tailscale
    ../../../misc/zfs-root
    ../../../misc/agenix
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

  services.withings2intervals = {
    enable = true;
    configFile = config.age.secrets.withings2intervals.path;
    authCodeFile = config.age.secrets.withings2intervals_authcode.path;
  };

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

  services.autoaspm.enable = true;
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
