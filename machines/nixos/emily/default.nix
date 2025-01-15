{
  lib,
  config,
  vars,
  pkgs,
  ...
}:
{
  boot.kernelModules = [
    "coretemp"
    "jc42"
    "lm78"
    "f71882fg"
  ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      vpl-gpu-rt # QSV on 11th gen or newer
    ];
  };
  boot.zfs.forceImportRoot = true;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "ata-Samsung_SSD_870_EVO_250GB_S6PENL0T902873K" ];
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
        "acpi_enforce_resources=lax"
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

  services.duckdns = {
    enable = true;
    domainsFile = config.age.secrets.duckDNSDomain.path;
    tokenFile = config.age.secrets.duckDNSToken.path;
  };

  imports = [
    ./filesystems
    ./backup
    ./homelab
  ];

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
    pwmPaths = [ "/sys/class/hwmon/hwmon1/device/pwm2" ];
    extraArgs = [
      "--pwm-start-value=50"
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
      trustedInterfaces = [
        "enp2s0"
        "tailscale0"
      ];
    };
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
}
