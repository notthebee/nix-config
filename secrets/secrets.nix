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
}
