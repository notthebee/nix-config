{ config, lib, ... }:

let
  cfg = config.zfs-root.fileSystems;
in
{
  options.zfs-root.fileSystems = {
    datasets = lib.mkOption {
      description = "Set mountpoint for datasets";
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
    efiSystemPartitions = lib.mkOption {
      description = "Set mountpoint for efi system partitions";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    enableDockerZvol = lib.mkOption {
      description = "Enable a separate ext4 zvol for Docker/Podman data";
      type = lib.types.bool;
      default = true;
    };
    bindmounts = lib.mkOption {
      description = "Set mountpoint for bindmounts";
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
  };
  config.fileSystems = lib.mkMerge (
    lib.mapAttrsToList (dataset: mountpoint: {
      "${mountpoint}" = {
        device = "${dataset}";
        fsType = "zfs";
        neededForBoot = true;
      };
    }) cfg.datasets
    ++ map (esp: {
      "/boot/efis/${esp}" = {
        device = "${config.zfs-root.boot.devNodes}/${esp}";
        fsType = "vfat";
        options = [
          "x-systemd.idle-timeout=1min"
          "x-systemd.automount"
          "noauto"
          "nofail"
          "noatime"
          "X-mount.mkdir"
        ];
      };
    }) cfg.efiSystemPartitions
    ++ lib.mapAttrsToList (bindsrc: mountpoint: {
      "${mountpoint}" = {
        device = "${bindsrc}";
        fsType = "none";
        options = [
          "bind"
          "X-mount.mkdir"
          "noatime"
        ];
      };
    }) cfg.bindmounts
    ++ lib.lists.optional cfg.enableDockerZvol {
      "/var/lib/containers" = {
        device = "/dev/zvol/rpool/docker";
        fsType = "ext4";
      };
    }
  );
}
