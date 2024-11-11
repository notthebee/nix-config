{
  pkgs,
  lib,
  networksLocal,
  ...
}:
let
  tvIpAddress =
    (lib.lists.findSingle (x: x.hostname == "lgtv") false false networksLocal.networks.iot.reservations)
    .ip-address;
  tvMacAddress =
    (lib.lists.findSingle (x: x.hostname == "lgtv") false false networksLocal.networks.iot.reservations)
    .hw-address;
in
{
  imports = [ ./lact.nix ];
  boot = {
    loader.systemd-boot.enable = true;
    kernelModules = [ "kvm-amd" ];
  };

  fileSystems."/" = {
    device = "dev/disk/by-id/nvme-CT1000P1SSD8_202629273359_1-part2";
    fsType = "ext4";
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd = {
      updateMicrocode = true;
      ryzen-smu.enable = true;
    };
    xone.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services = {
    openssh.enable = true;
    desktopManager.plasma6.enable = true;
    lgtv = {
      enable = true;
      ipAddress = tvIpAddress;
      macAddress = tvMacAddress;
      user = "notthebee";
      group = "notthebee";
    };
    ryzen-undervolt = {
      enable = true;
      offset = -25;
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = "maya";
    hostId = "899635ed";
  };

  jovian = {
    hardware = {
      has.amd.gpu = true;
    };
    steam = {
      updater.splash = "vendor";
      enable = true;
      autoStart = true;
      user = "notthebee";
      desktopSession = "plasma";
    };
    steamos = {
      useSteamOSConfig = true;
    };
  };
}
