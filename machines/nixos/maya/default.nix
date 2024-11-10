{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  fileSystems."/" = {
    device = "dev/disk/by-id/nvme-CT1000P1SSD8_202629273359_1-part2";
    fsType = "ext4";
  };
  hardware.xone.enable = true;
  services = {
    openssh.enable = true;
    desktopManager.plasma6.enable = true;
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
