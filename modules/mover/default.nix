{ config, pkgs, lib, ... }:
let
  inherit (builtins) head toString map tail concatStringsSep readFile;
  inherit (lib) mkIf types mkDefault mkOption mkMerge strings;
  mergerfs-uncache = pkgs.writeScriptBin "mergerfs-uncache" (readFile ./mergerfs-uncache.py);
in {

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
      default = [];
    };
    };

  config.environment.systemPackages = [ mergerfs-uncache ];

  config.security.sudo.extraRules = [{
    commands = [
      {
        command = "${pkgs.systemd}/bin/journalctl --unit=mergerfs-uncache.service *";
        options = [ "NOPASSWD" ];
      }];
      groups = [ "share" ];
      }];

  config.systemd = {
    services.mergerfs-uncache = {
      description = "MergerFS Mover script";
      path = [
        pkgs.rsync
        pkgs.python3
        pkgs.systemd
        pkgs.coreutils
        pkgs.gawk
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/mergerfs-uncache -s ${config.mover.cacheArray} -d ${config.mover.backingArray} -t ${config.mover.percentageFree} --exclude ${config.mover.excludedPaths}";
        User = "share";
        Group = "share";
      };
    postStop = ''
      message=$(/run/wrappers/bin/sudo journalctl --unit=mergerfs-uncache.service -n 20 --no-pager)
      /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "mergerfs-uncache Mover" -m "$message"
      '';
    };
    timers.mergerfs-uncache = {
      wantedBy = ["multi-user.target"];
      timerConfig = {
        OnCalendar = "Sat 00:00:00";
        Unit = "mergerfs-uncache.service";
      };
    };
  };
}
