let
  notthebee = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhpfgRj6BrVcJ160+D54X7OVlZOVdYYmlGPwQmWdKdH root@emily";
  allKeys = [notthebee system];
in {
  "hashedUserPassword.age".publicKeys = allKeys;
  "sambaPassword.age".publicKeys = allKeys;
  "smtpPassword.age".publicKeys = allKeys;
  "telegramChannelId.age".publicKeys = allKeys;
  "telegramApiKey.age".publicKeys = allKeys;
  "wireguardCredentials.age".publicKeys = allKeys;
  "cloudflareDnsApiCredentials.age".publicKeys = allKeys;
  "invoiceNinja.age".publicKeys = allKeys;
  "radarrApiKey.age".publicKeys = allKeys;
  "sonarrApiKey.age".publicKeys = allKeys;
  "tailscaleAuthKey.age".publicKeys = allKeys;
  "paperless.age".publicKeys = allKeys;
  "resticBackblazeEnv.age".publicKeys = allKeys;
  "resticPassword.age".publicKeys = allKeys;
  "wireguardPrivateKey.age".publicKeys = allKeys;
  "wireguardPrivateKeyAlison.age".publicKeys = allKeys;
  "bwSession.age".publicKeys = allKeys;
  "icloudDrive.age".publicKeys = allKeys;
  "icloudDriveUsername.age".publicKeys = allKeys;
  "pingvinCloudflared.age".publicKeys = allKeys;
  "jellyfinApiKey.age".publicKeys = allKeys;
  "duckDNSDomain.age".publicKeys = allKeys;
  "duckDNSToken.age".publicKeys = allKeys;
  "borgBackupSSHKey.age".publicKeys = allKeys;
  "borgBackupKey.age".publicKeys = allKeys;
  "ariaImmichDatabase.age".publicKeys = allKeys;
  "matrixRegistrationSecret.age".publicKeys = allKeys;
}
