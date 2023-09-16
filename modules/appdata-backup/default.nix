{ vars, config, pkgs, ...}:
{
  systemd.tmpfiles.rules = [
  "d ${vars.mainArray}/Backups/restic 0775 share share - -"
  ];

  environment.systemPackages = with pkgs; [
    restic
  ];

  users = {
  users.restic = {
    isSystemUser = true;
    extraGroups = [
    "share"
    ];
  };
  };
  services.restic = {
    server = {
      enable = true;
      dataDir = "${vars.mainArray}/Backups/restic";
      extraFlags = [
        "--no-auth"
      ];
    };
    backups.appdata-local = {
      timerConfig = {
        OnCalendar = "Mon...Sat *-*-* 05:00:00";
        Persistent = true;
      };
      repository = "rest:http://localhost:8000/appdata-local";
      initialize = true;
      passwordFile = config.age.secrets.resticPassword.path;
      pruneOpts = [
        "--keep-last 20"
      ];
      exclude = [
        "recyclarr/repo"
        "recyclarr/repositories"
      ];
      paths = [
        "${vars.serviceConfigRoot}"
      ];
      backupPrepareCommand = ''
      systemctl stop podman-*
      ${pkgs.restic}/bin/restic -r "${config.services.restic.backups.appdata-local.repository}" -p ${config.age.secrets.resticPassword.path} unlock
      '';
      backupCleanupCommand = ''
      systemctl start --all "podman-*"
      if [[ $SERVICE_RESULT =~ "success" ]]; then
        message=$(journalctl -xeu restic-backups-appdata-local | grep Files: | tail -1 | sed 's/^.*Files/Files/g')
      else
        message=$(journalctl --unit=restic-backups-appdata-local.service -n 20 --no-pager)
      fi
      /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "Backup Job appdata-local" -m "$message"
      '';
    };
    backups.appdata-backblaze = {
      timerConfig = {
        OnCalendar = "Sun *-*-* 05:00:00";
        Persistent = true;
      };
      environmentFile = config.age.secrets.resticBackblazeEnv.path;
      repository = "s3:https://s3.eu-central-003.backblazeb2.com/notthebee-docker-appdata";
      initialize = true;
      passwordFile = config.age.secrets.resticPassword.path;
      pruneOpts = [
        "--keep-last 10"
      ];
      exclude = [
        "recyclarr/repo"
        "recyclarr/repositories"
      ];
      paths = [
        "${vars.serviceConfigRoot}"
      ];
      backupPrepareCommand = ''
      systemctl stop podman-*
      ${pkgs.restic}/bin/restic -r "${config.services.restic.backups.appdata-backblaze.repository}" -p ${config.age.secrets.resticPassword.path} unlock
      '';
      backupCleanupCommand = ''
      systemctl start --all "podman-*"
      if [[ $SERVICE_RESULT =~ "success" ]]; then
        message=$(journalctl -xeu restic-backups-appdata-backblaze | grep Files: | tail -1 | sed 's/^.*Files/Files/g')
      else
        message=$(journalctl --unit=restic-backups-appdata-backblaze.service -n 20 --no-pager)
      fi
      /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "Backup Job appdata-backblaze" -m "$message"
      '';
    };
  };
}
