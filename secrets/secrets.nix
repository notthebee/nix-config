let
  notthebee = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhpfgRj6BrVcJ160+D54X7OVlZOVdYYmlGPwQmWdKdH root@emily";
  allKeys = [notthebee system];
in {
  "hashedUserPassword.age".publicKeys = allKeys;
  "sambaPassword.age".publicKeys = allKeys;
  "smtpPassword.age".publicKeys = allKeys;
}
