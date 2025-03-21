{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  emilyIpAddress =
    (lib.lists.findSingle (
      x: x.hostname == "emily"
    ) false false config.homelab.networks.local.lan.reservations).ip-address;
  gatewayIpAddress = config.homelab.networks.local.lan.cidr;
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
    interfaces.enp1s0f1 = {
      ipv4.addresses = [
        {
          address = emilyIpAddress;
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = gatewayIpAddress;
      interface = "enp1s0f1";
    };
    hostId = "0730ae51";
    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [
        "enp1s0f1"
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
      bootDevices = [ "ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K" ];
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
  ];

  services.duckdns = {
    enable = true;
    domainsFile = config.age.secrets.duckDNSDomain.path;
    tokenFile = config.age.secrets.duckDNSToken.path;
  };

  services.adiosBot = {
    enable = true;
    botTokenFile = config.age.secrets.adiosBotToken.path;
  };

  services.hddfancontrol = {
    enable = true;
    disks = [
      "/dev/disk/by-label/Data1"
      "/dev/disk/by-label/Data2"
      "/dev/disk/by-label/Parity1"
    ];
    pwmPaths = [ "/sys/class/hwmon/hwmon2/device/pwm2" ];
    extraArgs = [
      "--pwm-start-value=50"
      "--pwm-stop-value=50"
      "--smartctl"
      "-i 30"
      "--spin-down-time=900"
    ];
  };

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true;

  services.mover = {
    enable = true;
    cacheArray = vars.cacheArray;
    backingArray = vars.slowArray;
    user = config.homelab.user;
    group = config.homelab.group;
    percentageFree = 60;
    excludedPaths = [
      "Media/Music"
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
    go
    gotools
    gopls
    go-outline
    gopkgs
    gocode-gomod
    godef
    golint
    cpufrequtils
    gnumake
    gcc
    intel-gpu-tools
    powertop
  ];

  tg-notify = {
    enable = true;
    credentialsFile = config.age.secrets.tgNotifyCredentials.path;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
  ];
}
