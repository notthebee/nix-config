{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zfs-root.boot;
in
{
  options.zfs-root.boot = {
    enable = lib.mkOption {
      description = "Enable root on ZFS support";
      type = lib.types.bool;
      default = true;
    };
    devNodes = lib.mkOption {
      description = "Specify where to discover ZFS pools";
      type = lib.types.str;
      apply =
        x:
        assert (lib.strings.hasSuffix "/" x || abort "devNodes '${x}' must have trailing slash!");
        x;
      default = "/dev/disk/by-id/";
    };
    bootDevices = lib.mkOption {
      description = "Specify boot devices";
      type = lib.types.nonEmptyListOf lib.types.str;
    };
    availableKernelModules = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      default = [
        "uas"
        "nvme"
        "ahci"
      ];
    };
    immutable = lib.mkOption {
      description = "Enable root on ZFS immutable root support";
      type = lib.types.bool;
      default = true;
    };
    removableEfi = lib.mkOption {
      description = "install bootloader to fallback location";
      type = lib.types.bool;
      default = true;
    };
    partitionScheme = lib.mkOption {
      default = {
        biosBoot = "-part4";
        efiBoot = "-part2";
        bootPool = "-part1";
        rootPool = "-part3";
      };
      description = "Describe on disk partitions";
      type = lib.types.attrsOf lib.types.str;
    };
  };
  config = lib.mkIf (cfg.enable) (
    lib.mkMerge [
      (lib.mkIf (!cfg.immutable) {
        zfs-root.fileSystems.datasets = {
          "rpool/nixos/root" = "/";
        };
      })
      (lib.mkIf cfg.immutable {
        zfs-root.fileSystems = {
          datasets = {
            "rpool/nixos/empty" = "/";
          };
        };
        boot.initrd.systemd = {
          enable = true;
          services.initrd-rollback-root = {
            after = [ "zfs-import-rpool.service" ];
            wantedBy = [ "initrd.target" ];
            before = [
              "sysroot.mount"
            ];
            path = [ pkgs.zfs ];
            description = "Rollback root fs";
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = "zfs rollback -r rpool/nixos/empty@start && echo '  >> >> rollback complete << <<'";
          };
        };
      })
      {
        zfs-root.fileSystems = {
          efiSystemPartitions = (map (diskName: diskName + cfg.partitionScheme.efiBoot) cfg.bootDevices);
          datasets = {
            "bpool/nixos/root" = "/boot";
            "rpool/nixos/config" = "/etc/nixos";
            "rpool/nixos/nix" = "/nix";
            "rpool/nixos/home" = "/home";
            "rpool/nixos/persist" = "/persist";
            "rpool/nixos/var/log" = "/var/log";
            "rpool/nixos/var/lib" = "/var/lib";
          };
        };
        boot = {
          initrd.availableKernelModules = cfg.availableKernelModules;
          supportedFilesystems = [ "zfs" ];
          zfs = {
            devNodes = cfg.devNodes;
            forceImportRoot = lib.mkDefault false;
          };
          loader = {
            efi = {
              canTouchEfiVariables = (if cfg.removableEfi then false else true);
              efiSysMountPoint = ("/boot/efis/" + (builtins.head cfg.bootDevices) + cfg.partitionScheme.efiBoot);
            };
            generationsDir.copyKernels = true;
            grub =
              {
                enable = true;
                mirroredBoots = map (diskName: {
                  devices = [ "nodev" ];
                  path = "/boot/efis/${diskName}${cfg.partitionScheme.efiBoot}";
                }) cfg.bootDevices;
                efiInstallAsRemovable = cfg.removableEfi;
                copyKernels = true;
                efiSupport = true;
                zfsSupport = true;
              }
              // (
                if (builtins.lessThan 2 (builtins.length cfg.bootDevices)) then
                  {
                    mirroredBoots = map (diskName: {
                      devices = [ "nodev" ];
                      path = "/boot/efis/${diskName}${cfg.partitionScheme.efiBoot}";
                    }) cfg.bootDevices;
                    extraInstallCommands = (
                      toString (
                        map (diskName: ''
                          set -x
                          ${pkgs.coreutils-full}/bin/cp -r ${config.boot.loader.efi.efiSysMountPoint}/EFI /boot/efis/${diskName}${cfg.partitionScheme.efiBoot}
                          set +x
                        '') (builtins.tail cfg.bootDevices)
                      )
                    );
                  }
                else
                  { device = "nodev"; }
              );
          };
        };
      }
    ]
  );
}
