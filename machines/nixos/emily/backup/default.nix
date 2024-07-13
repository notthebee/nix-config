{ vars, users, pkgs, config, lib, ...}: 
{
  systemd.tmpfiles.rules = [
    "d ${vars.mainArray}/Backups/restic 0775 share share - -"
  ];

  environment.systemPackages = with pkgs; [
    restic
  ];

  services.borgbackup.jobs.parents-backup = {
    doInit = false;
    paths = [
      "${vars.mainArray}/YoutubeArchive"
      "${vars.cacheArray}/Documents"
    ];
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.age.secrets.borgBackupKey.path}";
    };
    extraArgs = "--verbose --progress";
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${config.age.secrets.borgBackupSSHKey.path}";
    environment.BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
    repo = "ssh://share@aria-tailscale:69${vars.slowArray}/YouTube";
    compression = "auto,zstd";
    startAt = "monthly";
  };

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
    backups = {
      appdata-local = {
        timerConfig = {
          OnCalendar = "Mon..Sat *-*-* 05:00:00";
          Persistent = true;
        };
        repository = "rest:http://localhost:8000/appdata-local-${config.networking.hostName}";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        pruneOpts = [
          "--keep-last 5"
        ];
        exclude = [
          "recyclarr/repo"
            "recyclarr/repositories"
            "pingvin/backend/uploads"
        ];
        paths = [
          "/tmp/appdata-local-${config.networking.hostName}.tar"
        ];
        backupPrepareCommand = ''
          ${pkgs.systemd}/bin/systemctl stop podman-*
          ${pkgs.gnutar}/bin/tar -cf /tmp/appdata-local-${config.networking.hostName}.tar /persist 
          ${pkgs.restic}/bin/restic -r "${config.services.restic.backups.appdata-local.repository}" -p ${config.age.secrets.resticPassword.path} unlock
          '';
        backupCleanupCommand = ''
          rm -rf /tmp/appdata-local*
          ${pkgs.systemd}/bin/systemctl start --all "podman-*"
          if [[ $SERVICE_RESULT =~ "success" ]]; then
            message=$(journalctl -xeu restic-backups-appdata-local | grep Files: | tail -1 | sed 's/^.*Files/Files/g')
          else
            message=$(journalctl --unit=restic-backups-appdata-local.service -n 20 --no-pager)
              fi
              /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "Backup Job appdata-local" -m "$message"
              '';
      };
      paperless-backblaze = {
        timerConfig = {
          OnCalendar = "Sun *-*-* 05:00:00";
          Persistent = true;
        };
        environmentFile = config.age.secrets.resticBackblazeEnv.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/notthebee-paperless-documents";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        pruneOpts = [
          "--keep-last 5"
        ];
        paths = [
          "${vars.cacheArray}/Documents"
        ];
        backupPrepareCommand = ''
          ${pkgs.restic}/bin/restic -r "${config.services.restic.backups.paperless-backblaze.repository}" -p ${config.age.secrets.resticPassword.path} unlock
          '';
        backupCleanupCommand = ''
          if [[ $SERVICE_RESULT =~ "success" ]]; then
            message=$(journalctl -xeu restic-backups-paperless-backblaze | grep Files: | tail -1 | sed 's/^.*Files/Files/g')
          else
            message=$(journalctl --unit=restic-backups-paperless-backblaze.service -n 20 --no-pager)
              fi
              /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "Backup Job paperless-backblaze" -m "$message"
              '';
      };
      appdata-backblaze = {
        timerConfig = {
          OnCalendar = "Sun *-*-* 05:00:00";
          Persistent = true;
        };
        environmentFile = config.age.secrets.resticBackblazeEnv.path;
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/notthebee-docker-appdata";
        initialize = true;
        passwordFile = config.age.secrets.resticPassword.path;
        pruneOpts = [
          "--keep-last 5"
        ];
        exclude = [
          "recyclarr/repo"
          "recyclarr/repositories"
          "pingvin/backend/uploads"
        ];
        paths = [
          "/tmp/appdata-backblaze-${config.networking.hostName}.tar"
        ];
        backupPrepareCommand = ''
          ${pkgs.restic}/bin/restic forget --prune --no-cache --keep-last 5
          ${pkgs.systemd}/bin/systemctl stop podman-*
          ${pkgs.gnutar}/bin/tar -cf /tmp/appdata-backblaze-${config.networking.hostName}.tar /persist 
          ${pkgs.restic}/bin/restic -r "${config.services.restic.backups.appdata-backblaze.repository}" -p ${config.age.secrets.resticPassword.path} unlock
          '';
        backupCleanupCommand = ''
          rm -rf /tmp/appdata-backblaze*.tar
          ${pkgs.systemd}/bin/systemctl start --all "podman-*"
          if [[ $SERVICE_RESULT =~ "success" ]]; then
            message=$(journalctl -xeu restic-backups-appdata-backblaze | grep Files: | tail -1 | sed 's/^.*Files/Files/g')
          else
            message=$(journalctl --unit=restic-backups-appdata-backblaze.service -n 20 --no-pager)
              fi
              /run/current-system/sw/bin/notify -s "$SERVICE_RESULT" -t "Backup Job appdata-backblaze" -m "$message"
              '';
      };
    };
  };
}
