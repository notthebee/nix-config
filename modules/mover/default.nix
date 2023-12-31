{ pkgs, ... }:
let
mergerfs-uncache = pkgs.writeScriptBin "mergerfs-uncache" (builtins.readFile ./mergerfs-uncache.py);
in
{
  environment.systemPackages = [ mergerfs-uncache ];

  security.sudo.extraRules = [{
    commands = [
      {
        command = "${pkgs.systemd}/bin/journalctl --unit=mergerfs-uncache.service *";
        options = [ "NOPASSWD" ];
      }];
      groups = [ "share" ];
      }];

  systemd = {
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
        Type = "simple";
        ExecStart = "/run/current-system/sw/bin/mergerfs-uncache -s <cache-fs> -d <backing-pool> -t 50 --exclude";
        User = "share";
        Group = "share";
      };
    postStop = ''
      ts=$(systemctl show -p ActiveEnterTimestamp mergerfs-uncache.service | awk '{print $2 $3}')
      message=$(/run/wrappers/bin/sudo journalctl --unit=mergerfs-uncache.service --since "$ts" --no-pager)
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
