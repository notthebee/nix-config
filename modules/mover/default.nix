{ pkgs, ... }:
let
mergerfs-uncache = pkgs.writeScriptBin "mergerfs-uncache" (builtins.readFile ./mergerfs-uncache.py);
in
{
  environment.systemPackages = [ mergerfs-uncache ];

  systemd = {
    services.mergerfs-uncache = {
      description = "MergerFS Mover script";
      path = [
        pkgs.rsync
        pkgs.python3
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "/run/current-system/sw/bin/mergerfs-uncache -s <cache-fs> -d <backing-pool> -t 50 --exclude";
      };
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


