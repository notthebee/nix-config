{ config, pkgs, lib, ... }:
let
  inherit (builtins) head toString map tail concatStringsSep readFile;
  inherit (lib) mkIf types mkDefault mkOption mkMerge strings;
  mergerfs-uncache = pkgs.writeScriptBin "mergerfs-uncache" (readFile ./mergerfs-uncache.py);
in
{

  options.mover = {
    cacheArray = mkOption {
      description = "The drive aray to move the data from";
      type = types.str;
      default = "/mnt/cache";
    };
    backingArray = mkOption {
      description = "The drive array to move the data to";
      type = types.str;
      default = "/mnt/mergerfs_slow";
    };
    percentageFree = mkOption {
      description = "The target free percentage of the SSD cache array";
      type = types.int;
      apply = old: toString old;
      default = 50;
    };
    excludedPaths = mkOption {
      description = "List of paths that should be excluded from moving";
      type = types.listOf types.str;
      apply = old: lib.strings.concatStringsSep " " (map (x: config.mover.cacheArray + "/" + x) old);
      default = [ ];
    };
    user = mkOption {
      description = "User to run the script as";
      type = types.str;
      default = "share";
    };
    group = mkOption {
      description = "Group to run the script as";
      type = types.str;
      default = "share";
    };

  };

  config.environment.systemPackages = [
    mergerfs-uncache
    (pkgs.python312Full.withPackages (ps: with ps; [
      aiofiles
    ]))
  ];

  config.security.sudo.extraRules = [{
    users = [ config.mover.user ];
    commands = [
      {
        command = "/run/current-system/sw/bin/journalctl --unit=mergerfs-uncache.service *";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/chown -R ${config.mover.user}\\:${config.mover.group} ${config.mover.backingArray}";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/chown -R ${config.mover.user}\\:${config.mover.group} ${config.mover.cacheArray}";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/chmod -R u=rwX\\,go=rX ${config.mover.backingArray}";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/chmod -R u=rwX\\,go=rX ${config.mover.cacheArray}";
        options = [ "NOPASSWD" ];
      }
    ];
  }];

  config.systemd = {
    services.mergerfs-uncache = {
      description = "MergerFS Mover script";
      path = [
        pkgs.rsync
        (pkgs.python312Full.withPackages (ps: with ps; [
          aiofiles
        ]))
        pkgs.systemd
        pkgs.coreutils
        pkgs.gawk
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/mergerfs-uncache -s ${config.mover.cacheArray} -d ${config.mover.backingArray} -t ${config.mover.percentageFree} --exclude ${config.mover.excludedPaths} -u ${config.mover.user} -g ${config.mover.group}";
        User = config.mover.user;
        Group = config.mover.group;
      };
      postStop = ''
        message=$(/run/wrappers/bin/sudo /run/current-system/sw/bin/journalctl --unit=mergerfs-uncache.service -n 20 --no-pager)
        /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "mergerfs-uncache Mover" -m "$message"
      '';
    };
    timers.mergerfs-uncache = {
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnCalendar = "Sat 00:00:00";
        Unit = "mergerfs-uncache.service";
      };
    };
  };
}
