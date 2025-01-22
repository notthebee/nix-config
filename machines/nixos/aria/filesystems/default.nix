{
  config,
  vars,
  pkgs,
  ...
}:
{

  imports = [
    ./snapraid.nix
  ];

  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    gptfdisk
    xfsprogs
    parted
    snapraid
    mergerfs
    mergerfs-tools
  ];

  # This fixes the weird mergerfs permissions issue
  boot.initrd.systemd.enable = true;

  fileSystems."/mnt/user" = {
    device = "rpool/nixos/data";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/mnt/data3" = {
    device = "/dev/disk/by-label/Data3";
    fsType = "xfs";
  };

  fileSystems."/mnt/data4" = {
    device = "/dev/disk/by-label/Data4";
    fsType = "xfs";
  };

  fileSystems."/mnt/data2" = {
    device = "/dev/disk/by-label/Data2";
    fsType = "xfs";
  };

  fileSystems."/mnt/data1" = {
    device = "/dev/disk/by-label/Data1";
    fsType = "xfs";
  };

  fileSystems."/mnt/parity1" = {
    device = "/dev/disk/by-label/Parity1";
    fsType = "xfs";
  };

  fileSystems.${vars.slowArray} = {
    device = "/mnt/data*";
    options = [
      "category.create=ff"
      "defaults"
      "allow_other"
      "moveonenospc=1"
      "minfreespace=50G"
      "func.getattr=newest"
      "fsname=mergerfs_slow"
      "uid=994"
      "gid=993"
      "umask=002"
      "x-mount.mkdir"
    ];
    fsType = "fuse.mergerfs";
  };

  services.smartd = {
    enable = true;
    defaults.autodetected = "-a -o on -S on -s (S/../.././02|L/../../6/03) -n standby,q";
    notifications = {
      wall = {
        enable = true;
      };
      mail = {
        enable = true;
        sender = config.email.fromAddress;
        recipient = config.email.toAddress;
      };
    };
  };

}
