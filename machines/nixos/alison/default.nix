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
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "nvme-WD_BLACK_SN770_500GB_22453P805347" ];
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
      hostName = "alison";
      hostId = "73cd46a7";
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
