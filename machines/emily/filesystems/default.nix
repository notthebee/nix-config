{ inputs, config, lib, vars, pkgs, ... }:
{

  imports = [
    ./snapraid.nix
  ];

  environment.systemPackages = with pkgs; [
    gptfdisk
    xfsprogs
    parted
    snapraid
    mergerfs
  ];
  fileSystems."/" =
  { device = "rpool/nixos/root";
    fsType = "zfs";
  };

  fileSystems."/boot" =
  { device = "bpool/nixos/root";
    fsType = "zfs";
  };

  fileSystems."/home" =
  { device = "rpool/nixos/home";
    fsType = "zfs";
  };

  fileSystems."/var/lib" =
  { device = "rpool/nixos/var/lib";
    fsType = "zfs";
  };

  fileSystems."/var/log" =
  { device = "rpool/nixos/var/log";
    fsType = "zfs";
  };

  fileSystems.${vars.cacheArray} =
  { device = "cache";
    fsType = "zfs";
  };

  fileSystems."/mnt/data1" =
  { device = "/dev/disk/by-label/Data1";
    fsType = "xfs";
  };

  fileSystems."/mnt/data2" =
  { device = "/dev/disk/by-label/Data2";
    fsType = "xfs";
  };

  fileSystems."/mnt/parity1" =
  { device = "/dev/disk/by-label/Parity1";
    fsType = "xfs";
  };

  fileSystems.${vars.slowArray} = 
  { device = "/mnt/data*";
    options = [
      "direct_io"
        "defaults"
        "allow_other"
        "moveonenospc=1"
        "minfreespace=1M"
        "func.getattr=newest"
        "fsname=mergerfs_slow"
        "uid=994"
        "gid=993"
        "umask=002"
    ];
    fsType = "fuse.mergerfs";
  };

  fileSystems.${vars.mainArray} = 
  { device = "/mnt/cache:/mnt/mergerfs_slow";
    options = [
      "category.create=lfs"
        "direct_io"
        "defaults"
        "allow_other"
        "moveonenospc=1"
        "minfreespace=1M"
        "func.getattr=newest"
        "fsname=user"
        "uid=994"
        "gid=993"
        "umask=002"
    ];
    fsType = "fuse.mergerfs";
  };
}
