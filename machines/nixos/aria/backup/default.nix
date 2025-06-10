{
  config,
  ...
}:
let
  hl = config.homelab;
in
{

  services.borgbackup.repos = {
    parents-backup = {
      user = "share";
      group = "share";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqm1UH6IXKfeZLaAv1qoWxXDo/uClg6o5kDU+2XYVBf notthebee@meredith"
      ];
      path = "${hl.mounts.slow}/YouTube";
    };
  };
}
