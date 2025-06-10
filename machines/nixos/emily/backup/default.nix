{
  config,
  ...
}:
let
  hl = config.homelab;
in
{
  services.borgbackup.jobs.parents-backup = {
    doInit = false;
    paths = [
      "${hl.mounts.merged}/YoutubeArchive"
      "${hl.mounts.fast}/Documents"
    ];
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.age.secrets.borgBackupKey.path}";
    };
    extraArgs = "--verbose --progress";
    environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i ${config.age.secrets.borgBackupSSHKey.path}";
    environment.BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
    repo = "ssh://share@aria-tailscale:69${hl.mounts.slow}/YouTube";
    compression = "auto,zstd";
    startAt = "monthly";
  };
}
