{ config, pkgs, lib, ... }: 
{
  nix.settings.trusted-users = [ "notthebee" ];

  age.identityPaths = [
    "/home/notthebee/.ssh/notthebee"
    "/home/notthebee/.ssh/id_ed25519"
  ];

  age.secrets.hashedUserPassword = {
    file = ../../secrets/hashedUserPassword.age;
  };

  email = {
    fromAddress = "moe@notthebe.ee";
    toAddress = "server_announcements@mailbox.org";
    smtpServer = "email-smtp.eu-west-1.amazonaws.com";
    smtpUsername = "AKIAYYXVLL34J7LSXFZF";
    smtpPasswordPath = config.age.secrets.smtpPassword.path;
  };


  users = {
    users = {
      notthebee = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.hashedUserPassword.path;
        extraGroups = [ "wheel" "users" "video" "podman" ];
        group = "notthebee";
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee" ];
      };
    };
    groups = {
      notthebee = {
        gid= 1000;
      };
    };
  };
  programs.zsh.enable = true;
}
