{ inputs, config, lib, vars, pkgs, ... }:
{

  imports = [
    ./snapraid.nix
  ];

  services.zfs = {
    autoScrub.enable = true;
    zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = [ config.email.toAddress ];
      ZED_EMAIL_PROG = "/run/current-system/sw/bin/notify";
      ZED_EMAIL_OPTS = "-t '@SUBJECT@' -m";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
  };
    zed.enableMail = false;
  };

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

  fileSystems."/" = lib.mkForce
  { device = "rpool/nixos/empty";
    fsType = "zfs";
  };

  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    wantedBy = [
      "initrd.target"
    ]; 
    after = [
      "zfs-import-zroot.service"
    ];
    before = [ 
      "sysroot.mount"
    ];
    path = with pkgs; [
      zfs
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool/nixos/empty@start
    '';
  };


  fileSystems."/nix" =
  { device = "rpool/nixos/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/etc/nixos" =
  { device = "rpool/nixos/config";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/boot" =
  { device = "bpool/nixos/root";
    fsType = "zfs";
  };

  fileSystems."/home" =
  { device = "rpool/nixos/home";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/persist" =
  { device = "rpool/nixos/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/var/log" =
  { device = "rpool/nixos/var/log";
    fsType = "zfs";
  };

  fileSystems."/var/lib/containers" =
  { device = "/dev/zvol/rpool/docker";
    fsType = "ext4";
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

  fileSystems.${vars.mainArray} = 
  { device = "${vars.cacheArray}:${vars.slowArray}";
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

}
