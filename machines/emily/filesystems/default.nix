{ config, lib, pkgs, ... }:
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
    [email]
    sendon = success,error
    short = true
    subject = [SnapRAID] Status Report:
    from = ${config.email.fromAddress}
    to = ${config.email.toAddress}
    maxsize = 500

    [smtp]
    host = ${config.email.smtpServer}
    port = 465
    tls = true
    user = ${config.email.smtpUsername}
    password = @smtpPassword@

    [scrub]
    ; set to true to run scrub after sync
    enabled = true
    percentage = 22
    older-than = 8
    '';
    mode = "0644";
    };
    };

  system.activationScripts."snapraid.smtpPassword" = ''
    smtpPassword=$(cat "${config.email.smtpPasswordPath}")
    ${pkgs.gnused}/bin/sed -i "s#@smtpPassword@#$smtpPassword#" /etc/snapraid-runner.conf;
  '';

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

  fileSystems."/mnt/cache" =
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

  fileSystems."/mnt/mergerfs_slow" = 
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
    ];
    fsType = "fuse.mergerfs";
  };

  fileSystems."/mnt/user" = 
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
    ];
    fsType = "fuse.mergerfs";
  };
}
