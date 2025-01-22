{
  lib,
  pkgs,
  config,
  ...
}:
{
  boot.kernelModules = [
    "i915"
    "cp210x"
  ];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  boot.zfs.forceImportRoot = true;
  boot.kernelParams = [
    "pcie_aspm=force"
    "consoleblank=60"
  ];
  networking = {
    hostName = "alison";
    hostId = "73cd46a7";
    firewall = {
      enable = true;
    };
  };

  zfs-root = {
    boot = {
      bootDevices = [
        "nvme-PC601_NVMe_SK_hynix_256GB_AI97N00681CA38E2W"
        "nvme-Vi3000_Internal_PCIe_NVMe_M.2_SSD_256GB_493733094834956"
      ];
      immutable = false;
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
    ./router
    ./filesystems
  ];

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade = {
    allowReboot = lib.mkForce false;
  };

  homelab = {
    enable = true;
    cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
    baseDomain = "goose.party";
    timeZone = "Europe/Berlin";
    mounts = {
      config = "/persist/opt/services";
    };
    services = {
      enable = true;
      homeassistant.enable = true;
      raspberrymatic.enable = true;
      uptime-kuma.enable = true;
    };
  };
  services.caddy.globalConfig = ''
    default_bind ${config.homelab.networks.local.lan.cidr}
  '';
  environment.systemPackages = with pkgs; [
    pciutils
    smartmontools
    powertop
    cpufrequtils
    gnumake
    gcc
  ];
}
