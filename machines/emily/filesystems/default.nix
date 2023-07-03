{ config, libs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gptfdisk
    xfsprogs
    parted
    snapraid
    mergerfs
  ];


  # SnapRaid
  environment.etc = 
  { "snapraid.conf" =
  { source = ./snapraid.conf;
    mode = "0644";
    };
   "snapraid-runner.conf" = 
  { text = ''
    [snapraid]
    executable = ${pkgs.snapraid}/bin/snapraid
    config = /etc/snapraid.conf
    deletethreshold = 250
    touch = true

    [logging]
    file = snapraid.log
    maxsize = 5000

    [scrub]
    ; set to true to run scrub after sync
    enabled = true
    percentage = 22
    older-than = 8
    '';
    mode = "0644";
    };
    };


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

  fileSystems."/mnt/mergerfs_slow" = 
  { device = "/mnt/data*";
    options = [
    "direct_io"
    "defaults"
    "allow_other"
    "moveonenospc=1"
    "minfreespace=500G"
    "fsname=mergerfs_slow"
    "uid=1000"
    "gid=1000"
    ];
    fsType = "fuse.mergerfs";
    };
}
