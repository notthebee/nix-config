{ config, pkgs, ... }: {

  nix.settings.trusted-users = [ "notthebee" ];

  age.identityPaths = ["/home/notthebee/.ssh/notthebee"];

  age.secrets.hashedUserPassword = {
    file = ../../secrets/hashedUserPassword.age;
  };

  users.users = {
    notthebee = {
      shell = pkgs.fish;
      isNormalUser = true;
      passwordFile = config.age.secrets.hashedUserPassword.path;
      extraGroups = [ "wheel" "users" "video" "docker" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee" ];
      };
      };

      programs.fish.enable = true;

}
