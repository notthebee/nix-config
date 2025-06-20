{
  config,
  pkgs,
  ...
}:
let
  hl = config.homelab;
in
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

  fileSystems.${hl.mounts.fast} = {
    device = "cache";
    fsType = "zfs";
  };

  fileSystems."/mnt/data1" = {
    device = "/dev/disk/by-label/Data1";
    fsType = "xfs";
  };

  fileSystems."/mnt/data2" = {
    device = "/dev/disk/by-label/Data2";
    fsType = "xfs";
  };

  fileSystems."/mnt/data3" = {
    device = "/dev/disk/by-label/Data3";
    fsType = "xfs";
  };

  fileSystems."/mnt/parity1" = {
    device = "/dev/disk/by-label/Parity1";
    fsType = "xfs";
  };

  fileSystems.${hl.mounts.slow} = {
    device = "/mnt/data*";
    options = [
      "defaults"
      "allow_other"
      "moveonenospc=1"
      "minfreespace=1000G"
      "func.getattr=newest"
      "fsname=mergerfs_slow"
      "uid=994"
      "gid=993"
      "umask=002"
      "x-mount.mkdir"
    ];
    fsType = "fuse.mergerfs";
  };

  fileSystems.${hl.mounts.merged} = {
    device = "${hl.mounts.fast}:${hl.mounts.slow}";
    options = [
      "category.create=epff"
      "defaults"
      "allow_other"
      "moveonenospc=1"
      "minfreespace=500G"
      "func.getattr=newest"
      "fsname=user"
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
