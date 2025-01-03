{
  lib,
  pkgs,
  ...
}:
{
  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    gptfdisk
    parted
  ];

  fileSystems."/" = lib.mkForce {
    device = "rpool/nixos/empty";
    fsType = "zfs";
  };

  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-zroot.service" ];
    before = [ "sysroot.mount" ];
    path = with pkgs; [ zfs ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool/nixos/empty@start
    '';
  };

  fileSystems."/nix" = {
    device = "rpool/nixos/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/etc/nixos" = {
    device = "rpool/nixos/config";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "bpool/nixos/root";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/nixos/home";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "rpool/nixos/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "rpool/nixos/var/log";
    fsType = "zfs";
  };

  fileSystems."/var/lib/containers" = {
    device = "/dev/zvol/rpool/docker";
    fsType = "ext4";
  };
}
