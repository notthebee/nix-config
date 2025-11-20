{
  config,
  lib,
  pkgs,
  ...
}:
let
  hl = config.homelab;
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
        intel-compute-runtime
        vpl-gpu-rt
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

  networking =
    let
      mainIface = "enp1s0";
    in
    {
      useDHCP = false;
      networkmanager.enable = false;
      hostName = "emily";
      interfaces.${mainIface} = {
        ipv4.addresses = [
          {
            address = "192.168.2.199";
            prefixLength = 24;
          }
        ];
      };
      defaultGateway = {
        address = "192.168.2.1";
        interface = mainIface;
      };
      nameservers = [ "192.168.2.1" "8.8.8.8" ];
      hostId = "0730ae51";
      firewall = {
        enable = true;
        allowPing = true;
        trustedInterfaces = [
          mainIface
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
        "ata-Samsung_SSD_860_EVO_500GB_S3Z2NB0KC53819J"
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
    ./homelab
  ];

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true;

  services.autoaspm.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
    glances
    hdparm
    smartmontools
    cpufrequtils
    intel-gpu-tools
    powertop
  ];

  tg-notify = {
    enable = true;
    credentialsFile = "/persist/secrets/tgNotifyCredentials";
  };

  services.adiosBot = {
    enable = true;
    botTokenFile = "/persist/secrets/adiosBotToken";
  };
}
