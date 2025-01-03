{
  vars,
  config,
  ...
}:
{
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
}
