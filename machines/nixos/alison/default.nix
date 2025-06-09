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
  };

  zfs-root = {
    boot = {
      bootDevices = [
        "nvme-eui.ace42e0095548e4c2ee4ac0000000001"
        "nvme-nvme.1e4b-343933373333303934383334393536-56693330303020496e7465726e616c2050434965204e564d65204d2e3220535344203235364742-00000001"
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
    ./secrets
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
    default_bind ${config.homelab.networks.local.lan.cidr.v4}
  '';
  environment.systemPackages = with pkgs; [
    pciutils
    smartmontools
    powertop
    cpufrequtils
    gnumake
    gcc
    dig.dnsutils
  ];
}
