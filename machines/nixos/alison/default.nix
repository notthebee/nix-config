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
    ../../networks.nix
  ];

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade = {
    allowReboot = lib.mkForce false;
  };

  users = {
    groups.share = {
      gid = 993;
    };
    users.share = {
      uid = 994;
      isSystemUser = true;
      group = "share";
    };
  };

  homelab = {
    enable = true;
    baseDomainName = "goose.party";
    timeZone = "Europe/Berlin";
    mounts = {
      config = "/persist/opt/services";
    };
    services.traefik = {
      enable = true;
      listenAddress = config.homelab.networks.local.lan.cidr;
      acme = {
        email = config.email.fromAddress;
        dnsChallenge.credentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    pciutils
    smartmontools
    powertop
    cpufrequtils
    gnumake
    gcc
  ];
}
